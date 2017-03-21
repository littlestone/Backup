USE [PIM]
GO

/****** Object:  StoredProcedure [dbo].[spd_4DigitRootOver90%UsedReport]    Script Date: 2017-03-21 7:49:46 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
















































-- =============================================
-- Author:		Junjie Tang
-- Create date: 2016-11-21
-- Description:	Product Codes Reservation Service - 4 Digit Roots Over 90% Used Report 
-- =============================================
ALTER PROCEDURE [dbo].[spd_4DigitRootOver90%UsedReport]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	DECLARE @ResultTable TABLE
	(
	   [RootCode] [nvarchar](4) NOT NULL,
	   [TotalUsed] [int],
	   [GrandTotal] [int],
	   [Percent] [numeric]
	);
	
	DECLARE @TotalUsed AS NUMERIC, @GrandTotal AS NUMERIC, @Percent AS NUMERIC
	DECLARE @4DigitRootCode AS NVARCHAR(4)
	DECLARE @I AS INT = 7199
	
	WHILE @I < 8000
	BEGIN
	    -- set counter
		SET @I += 1;
	
		-- get per 4 digit root code
		SELECT @4DigitRootCode = CONVERT(varchar(4), @I)
	    
	    -- get total product codes used for the 4 digit root
		SELECT @TotalUsed = COUNT(*)
	    FROM [PIM].[dbo].[ProductCodesReservation]
	    WHERE ProductCode LIKE @4DigitRootCode + '%'
	    AND StatusCode <> 0
	
		-- get total product codes available for the 4 digit root
		SET @GrandTotal = 100
	
		-- calculate total product code usage percent for the 4 digit root
		SELECT @Percent = (@TotalUsed / @GrandTotal) * 100
	
		-- insert into result temporary table if greater than 90% used
		--IF @Percent > 90.0
		--BEGIN
			INSERT INTO @ResultTable
			SELECT @4DigitRootCode
			,	@TotalUsed
			,	@GrandTotal
			,	@Percent
		--END
	END
	
	-- return the 4 digit root code(s) matched
	SELECT *
	FROM @ResultTable
END






















GO


