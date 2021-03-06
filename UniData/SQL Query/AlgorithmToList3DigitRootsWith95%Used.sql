DECLARE @ResultTable TABLE
(
   [RootCode] [nvarchar](3) NOT NULL
);

DECLARE @TotalUsage AS NUMERIC, @GrandTotal AS NUMERIC, @TotalUsagePercent AS NUMERIC
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
	SELECT @TotalUsage = COUNT(*)
    FROM [PIM].[dbo].[ProductCodesReservation]
    WHERE ProductCode LIKE @3DigitRootCode + '%'
    AND StatusCode <> 0

	-- get total product codes available for the 3 digit root
	SELECT @GrandTotal = COUNT(*)
	FROM [PIM].[dbo].[ProductCodesReservation]
	WHERE ProductCode LIKE @3DigitRootCode + '%'

	-- calculate total product code usage percent for the 3 digit root
	SELECT @TotalUsagePercent = (@TotalUsage/@GrandTotal)*100

	-- insert into result temporary table if greater than 90%
	IF @TotalUsagePercent > 90.0
	BEGIN
		INSERT INTO @ResultTable
		SELECT @3DigitRootCode
	END
END

SELECT *
FROM @ResultTable