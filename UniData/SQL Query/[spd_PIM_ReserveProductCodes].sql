USE [PIM]
GO

/****** Object:  StoredProcedure [dbo].[spd_ReserveProductCodes]    Script Date: 2016-12-07 11:50:20 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



































-- =============================================
-- Author:		Junjie Tang
-- Create date: 2016-07-26
-- Description:	Product Codes Reservation Service for both PIM & Infoflo (Peek & Reserve)
-- =============================================
ALTER PROCEDURE [dbo].[spd_ReserveProductCodes]
	-- Add the parameters for the stored procedure here
	@NumberOfCodes INT,
	@OptionCode VARCHAR(10),
	@CompanyGroup VARCHAR(10),
	@RootForCodes VARCHAR(10),
	@Action INT,
	@SourceCode VARCHAR(1)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Declare local variable
	DECLARE @RowCount AS INT
	DECLARE @TestForRootCodes AS VARCHAR(6)
	SET @TestForRootCodes = @RootForCodes + REPLICATE('0', 6-LEN(@RootForCodes))

	-- Declare temporary table
	DECLARE @ResultTable TABLE (ProductCode VARCHAR(6))

	-- Parameters validations
	IF UPPER(@SourceCode) NOT IN ('I', 'P', 'D')  -- D is hidden from user which for debug/test purpose
	BEGIN
		RAISERROR('Invalid parameter { %s }: the correct source code is either I (Infoflo) or P (PIM).', 16, 1, @RowCount)
		RETURN -1
	END

	IF @NumberOfCodes > 25
	BEGIN
		RAISERROR('Invalid parameter { %d }: cannot reserve more than 25 product codes.', 16, 1, @NumberOfCodes)
		RETURN -1
	END

	IF @RootForCodes <> '' AND (LEN(@RootForCodes) > 6 OR ISNUMERIC(@RootForCodes) <> 1)
	BEGIN
		RAISERROR('Invalid parameter { %s }: product code is 6 numeric digits only.', 16, 1, @RootForCodes)
		RETURN -1
	END

	IF LEN(@OptionCode) <> 1 AND UPPER(@OptionCode) NOT IN ('C', 'P', 'F')
	BEGIN
		RAISERROR('Invalid parameter { %s }: acceptable value are C (consecutive), P (preferably consecutive) and F (first available).', 16, 1, @OptionCode)
		RETURN -1
	END

	IF LEN(@CompanyGroup) <> 3 AND UPPER(@CompanyGroup) NOT IN ('IPX', 'HMK', 'CPL', 'ALL')
	BEGIN
		RAISERROR('Invalid parameter { %s }: acceptable value are IPX, HMK, and CPL.', 16, 1, @CompanyGroup)
		RETURN -1
	END

	IF UPPER(@CompanyGroup) IN ('IPX', 'CPL') AND @RootForCodes <> '' AND (@TestForRootCodes < '001000' OR (@TestForRootCodes > '799999' AND @TestForRootCodes < '900000'))
	BEGIN	
		RAISERROR('Invalid parameter { %s -> %s }: acceptable product code range for IPX and CPL is 001000-799999 and 900000-999999.', 16, 1, @CompanyGroup, @RootForCodes)
		RETURN -1
	END

	IF UPPER(@CompanyGroup) = 'HMK' AND @RootForCodes <> '' AND (@TestForRootCodes < '800000' OR @TestForRootCodes > '899999')
	BEGIN
		RAISERROR('Invalid parameter { %s -> %s }: acceptable product code range for HMK is 800000-899999.', 16, 1, @CompanyGroup, @RootForCodes)
		RETURN -1
	END

	IF UPPER(@CompanyGroup) = 'ALL' AND @RootForCodes <> '' AND (@TestForRootCodes < '001000')
	BEGIN
		RAISERROR('Invalid parameter { %s -> %s }: acceptable product code range for ALL is 001000-999999.', 16, 1, @CompanyGroup, @RootForCodes)
		RETURN -1
	END

	IF @Action <> 0 AND @Action <> 1
	BEGIN
		RAISERROR('Invalid parameter { %d }: acceptable action code is 0 (release) or 1 (assign).', 16, 1, @NumberOfCodes)
		RETURN -1
	END

	-- Product code reservation option F (First Available)
	IF UPPER(@OptionCode) = 'F'
	BEGIN
		INSERT INTO @ResultTable
		SELECT TOP (@NumberOfCodes) [ProductCode]
		FROM [PIM].[dbo].[ProductCodesReservation]
		WHERE [StatusCode] = 0
		AND (@RootForCodes = '' OR [ProductCode] LIKE @RootForCodes + '%')
		AND ((@CompanyGroup IN ('IPX', 'CPL') AND [ProductCode] >= '001000' AND [ProductCode] <= '799999') OR
		     (@CompanyGroup IN ('IPX', 'CPL') AND [ProductCode] >= '900000' AND [ProductCode] <= '999999') OR
			 (@CompanyGroup = 'HMK' AND [ProductCode] >= '800000' AND [ProductCode] <= '899999') OR
			 (@CompanyGroup = 'ALL' AND [ProductCode] >= '001000' AND [ProductCode] <= '999999'))
	END

	-- Product code reservation option C (Consecutive)
	IF UPPER(@OptionCode) = 'C'
	BEGIN
	    IF LEN(@RootForCodes) = 6  -- i.e. product code itself
		BEGIN
			DECLARE @I AS INT = 0, @Number AS INT, @NextSeqProductCode AS NVARCHAR(6)
	        WHILE @I < @NumberOfCodes
			BEGIN
			    -- get next sequental product code base on the given 6 digits root number
			    SET @Number = CAST(RIGHT(@RootForCodes, 1) AS INT) + @I
			    SET @NextSeqProductCode = LEFT(@RootForCodes, 5) + CAST(@Number AS NVARCHAR(1))

				-- save the next sequental product code if not used
				INSERT INTO @ResultTable
				SELECT [ProductCode]
				FROM [PIM].[dbo].[ProductCodesReservation]
				WHERE [ProductCode] = @NextSeqProductCode
				AND [StatusCode] = 0

	            -- increase counter
				SET @I += 1
			END

			-- clear the @ResultTable if number of consectutive codes starting at the given root are not available
			DECLARE @Total AS INT = 0
			SELECT @Total = COUNT(*)
			FROM @ResultTable
			IF @Total <> @NumberOfCodes
			BEGIN
				DELETE FROM @ResultTable
		    END
		END
		ELSE  -- search the available consectutive product codes starting with the given root code
		BEGIN
			WITH partitioned AS (
				SELECT *,
					[ProductCode] - ROW_NUMBER() OVER (PARTITION BY [StatusCode] ORDER BY [StatusCode]) AS grp
				FROM [PIM].[dbo].[ProductCodesReservation]
				WHERE [StatusCode] = 0
				AND (@RootForCodes = '' OR [ProductCode] LIKE @RootForCodes + '%')
				AND ((@CompanyGroup IN ('IPX', 'CPL') AND [ProductCode] >= '001000' AND [ProductCode] <= '799999') OR
				     (@CompanyGroup IN ('IPX', 'CPL') AND [ProductCode] >= '900000' AND [ProductCode] <= '999999') OR
					 (@CompanyGroup = 'HMK' AND [ProductCode] >= '800000' AND [ProductCode] <= '899999') OR
			         (@CompanyGroup = 'ALL' AND [ProductCode] >= '001000' AND [ProductCode] <= '999999'))
			),  -- group consecutive numbers
			counted AS (
				SELECT *,
					COUNT(*) OVER (PARTITION BY [StatusCode], grp) AS cnt
				FROM partitioned
			), -- count how many consecutive product codes for each group
			ranked AS (
				SELECT *,
					RANK() OVER (ORDER BY [StatusCode], grp) AS rnk
				FROM counted
				WHERE cnt >= @NumberOfCodes
			)  -- rank each consecutive product code group with a set number
			INSERT INTO @ResultTable
			SELECT TOP (@NumberOfCodes) [ProductCode]
			FROM ranked
			WHERE rnk = 1  -- return only one set
			ORDER BY [ProductCode]
		END
	END

	-- Product code reservation option P (Preferably Consecutive)
	IF UPPER(@OptionCode) = 'P'
	BEGIN
		WITH partitioned AS (
			SELECT *,
				[ProductCode] - ROW_NUMBER() OVER (PARTITION BY [StatusCode] ORDER BY [StatusCode]) AS grp
			FROM [PIM].[dbo].[ProductCodesReservation]
			WHERE [StatusCode] = 0
			AND (@RootForCodes = '' OR [ProductCode] LIKE @RootForCodes + '%')
			AND ((@CompanyGroup IN ('IPX', 'CPL') AND [ProductCode] >= '001000' AND [ProductCode] <= '799999') OR
		         (@CompanyGroup IN ('IPX', 'CPL') AND [ProductCode] >= '900000' AND [ProductCode] <= '999999') OR
			     (@CompanyGroup = 'HMK' AND [ProductCode] >= '800000' AND [ProductCode] <= '899999') OR
			     (@CompanyGroup = 'ALL' AND [ProductCode] >= '001000' AND [ProductCode] <= '999999'))
		),  -- group consecutive numbers
		counted AS (
			SELECT *,
				COUNT(*) OVER (PARTITION BY [StatusCode], grp) AS cnt
			FROM partitioned
		), -- count how many consecutive product codes for each group
		ranked AS (
			SELECT *,
				RANK() OVER (ORDER BY [StatusCode], grp) AS rnk
			FROM counted
			WHERE cnt >= @NumberOfCodes
		)  -- rank each consecutive product code group with a set number
		INSERT INTO @ResultTable
		SELECT TOP (@NumberOfCodes) [ProductCode]
		FROM ranked
		WHERE rnk = 1  -- return only one set
		ORDER BY [ProductCode]

		SET @RowCount = @@ROWCOUNT

		-- Return first available if no concecutive match found 
		IF @RowCount <> @NumberOfCodes
		BEGIN
			INSERT INTO @ResultTable
			SELECT TOP (@NumberOfCodes) [ProductCode]
			FROM [PIM].[dbo].[ProductCodesReservation]
			WHERE [StatusCode] = 0  -- FREE
			AND (@RootForCodes = '' OR [ProductCode] LIKE @RootForCodes + '%')
			AND ((@CompanyGroup IN ('IPX', 'CPL') AND [ProductCode] >= '001000' AND [ProductCode] <= '799999') OR
		         (@CompanyGroup IN ('IPX', 'CPL') AND [ProductCode] >= '900000' AND [ProductCode] <= '999999') OR
			     (@CompanyGroup = 'HMK' AND [ProductCode] >= '800000' AND [ProductCode] <= '899999') OR
			     (@CompanyGroup = 'ALL' AND [ProductCode] >= '001000' AND [ProductCode] <= '999999'))

		END
	END

	-- Result
	IF @Action = 0
	BEGIN
		SELECT * FROM @ResultTable  -- matched product codes
		SET @RowCount = @@ROWCOUNT  -- retrieve the rowcount	
		RETURN @RowCount
	END
	ELSE
	BEGIN
		-- Reserve the matched product code(s)
		UPDATE [PIM].[dbo].[ProductCodesReservation]
		SET [StatusCode] = 1,				-- RESERVED
			[SourceCode] = @SourceCode,		-- I or P (Infoflo or PIM)
			[ts] = GETDATE()				-- timestamp
		WHERE EXISTS (
			SELECT [ProductCode] 
			FROM @ResultTable X
			WHERE X.ProductCode = [ProductCodesReservation].ProductCode
		)

		SELECT * FROM @ResultTable  -- matched product codes
		SET @RowCount = @@ROWCOUNT  -- retrieve the rowcount	
		RETURN @RowCount
	END

END



































GO


