USE [PIM]
GO

/****** Object:  StoredProcedure [dbo].[spd_3DigitRootOver90%UsedReport]    Script Date: 2017-02-18 1:35:58 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO














































-- =============================================
-- Author:		Junjie Tang
-- Create date: 2016-11-21
-- Description:	Product Codes Reservation Service - 3 Digit Roots Over 90% Used Report 
-- =============================================
ALTER PROCEDURE [dbo].[spd_3DigitRootOver90%UsedReport]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	DECLARE @ResultTable TABLE
	(
	   [RootCode] [nvarchar](3) NOT NULL,
	   [TotalUsed] [int],
	   [GrandTotal] [int],
	   [Percent] [numeric]
	);
	
	DECLARE @TotalUsed AS NUMERIC, @GrandTotal AS NUMERIC, @Percent AS NUMERIC
	DECLARE @3DigitRootCode AS NVARCHAR(3)
	DECLARE @I AS INT = 0
	
	WHILE @I < 999
	BEGIN
	    -- set counter
		SET @I += 1;
	
		-- get per 3 digit root code
		SELECT @3DigitRootCode = CASE WHEN LEN(@I) = 3 THEN CONVERT(varchar(3), @I)
				    				  WHEN LEN(@I) = 2 THEN '0' + CONVERT(varchar(2), @I)
									  WHEN LEN(@I) = 1 THEN '00' + CONVERT(varchar(1), @I)
								 END
	    
	    -- get total product codes used for the 3 digit root
		SELECT @TotalUsed = COUNT(*)
	    FROM [PIM].[dbo].[ProductCodesReservation]
	    WHERE ProductCode LIKE @3DigitRootCode + '%'
	    AND StatusCode <> 0
	
		-- get total product codes available for the 3 digit root
		--SELECT @GrandTotal = COUNT(*)
		--FROM [PIM].[dbo].[ProductCodesReservation]
		--WHERE ProductCode LIKE @3DigitRootCode + '%'
		SET @GrandTotal = 1000
	
		-- calculate total product code usage percent for the 3 digit root
		SELECT @Percent = (@TotalUsed / @GrandTotal) * 100
	
		-- insert into result temporary table if greater than 90% used
		--IF @Percent > 90.0
		--BEGIN
			INSERT INTO @ResultTable
			SELECT @3DigitRootCode
			,	@TotalUsed
			,	@GrandTotal
			,	@Percent
		--END
	END
	
	-- return the 3 digit root code(s) matched
	SELECT *
	FROM @ResultTable
END




















GO


