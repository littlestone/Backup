USE [PIM]
GO

/****** Object:  StoredProcedure [dbo].[spd_ReleaseProductCodes]    Script Date: 2016-11-23 5:11:56 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


































-- =============================================
-- Author:		Junjie Tang
-- Create date: 2016-07-29
-- Description:	Product Codes Reservation Service for both PIM & Infoflo (Release)
-- =============================================
ALTER PROCEDURE [dbo].[spd_ReleaseProductCodes]
	-- Add the parameters for the stored procedure here
	@ProductCodes VARCHAR(MAX),
	@SourceCode VARCHAR(1)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SET FMTONLY OFF

	-- Declare local variable
	DECLARE @RowCount AS INT
	DECLARE @InvalidProductCodes AS VARCHAR(MAX)

	-- Declare temporary table variables
	DECLARE @ResultTable TABLE (ProductCode VARCHAR(6))
	DECLARE @InvalidProductCodesTable TABLE (ProductCode VARCHAR(6))

	-- Validate parameter received: @SourceCode
	IF UPPER(@SourceCode) NOT IN ('I', 'P', 'D')  -- D is hidden from user which for debug/test purpose
	BEGIN
		RAISERROR('Invalid parameter { %s }: the correct source code is either I (Infoflo) or P (PIM).', 16, 1, @RowCount)
		RETURN -1
	END

	-- Parse received product codes (comma delimited string) into temporary table
	IF CHARINDEX(@ProductCodes, ',') = 0
	BEGIN
		INSERT @ResultTable
		SELECT @ProductCodes AS ProductCode
	END
	ELSE
	BEGIN
		INSERT @ResultTable
		SELECT REPLACE(value, ' ', '') AS ProductCode
		FROM dbo.SplitStrings_Numbers(@ProductCodes, ',')

		SET @RowCount = @@ROWCOUNT
		IF @RowCount > 25
		BEGIN
			RAISERROR('Invalid parameter { %d }: maximum number of product codes can be released at a time is 25.', 16, 1, @RowCount)
			RETURN -1
		END		
	END

	-- Make sure all requested product codes exists before we can release it
	INSERT @InvalidProductCodesTable
	SELECT *
	FROM @ResultTable p
	WHERE LEN(p.ProductCode) <> 6
	OR ISNUMERIC(p.ProductCode) <> 1
	OR NOT EXISTS (
		SELECT [ProductCode] 
		FROM [PIM].[dbo].[ProductCodesReservation]
		WHERE [ProductCode] = p.ProductCode
		AND [StatusCode] <> 2			-- ASSIGNED
		AND [SourceCode] = @SourceCode	-- Owner
		)
	SET @RowCount = @@ROWCOUNT
	IF @RowCount > 0 
	BEGIN
		SELECT @InvalidProductCodes = STUFF((SELECT ',' + ProductCode FROM @InvalidProductCodesTable FOR XML PATH('')),1,1,'')
		RAISERROR('Invalid parameter { %s }: this product code(s) is either invalid, already been assigned or not owned by you.', 16, 1, @InvalidProductCodes)
		RETURN -1
	END
	ELSE
	BEGIN
		-- Release the requested product code(s)
		UPDATE [PIM].[dbo].[ProductCodesReservation]
		SET [StatusCode] = 0,				-- FREE
			[SourceCode] = @SourceCode,		-- I or P (Infoflo or PIM)
			[ts] = GETDATE()				-- timestamp
		WHERE EXISTS (
			SELECT [ProductCode]
			FROM @ResultTable X
			WHERE X.ProductCode = [ProductCodesReservation].ProductCode
		)

		SELECT * FROM @ResultTable
		SET @RowCount = @@ROWCOUNT
		RETURN @RowCount
	END

END


































GO


