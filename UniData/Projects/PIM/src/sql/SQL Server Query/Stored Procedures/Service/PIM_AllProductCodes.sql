DECLARE @I INT = 0

WHILE @I < 999999
BEGIN
  SET @I += 1;
  INSERT INTO [DataWarehouse_PIM].[dbo].[PIM_AllProductCodes]
  SELECT CASE WHEN LEN(@I) = 1 THEN '00000' + CONVERT(varchar(1), @I)
              WHEN LEN(@I) = 2 THEN '0000' + CONVERT(varchar(2), @I)
			  WHEN LEN(@I) = 3 THEN '000' + CONVERT(varchar(3), @I)
			  WHEN LEN(@I) = 4 THEN '00' + CONVERT(varchar(4), @I)
			  WHEN LEN(@I) = 5 THEN '0' + CONVERT(varchar(5), @I)
			  WHEN LEN(@I) = 6 THEN CONVERT(varchar(6), @I)
		 END AS ProductCode
END

SELECT *
FROM [DataWarehouse_PIM].[dbo].[PIM_AllProductCodes]

-- TRUNCATE TABLE [DataWarehouse_PIM].[dbo].[PIM_AllProductCodes]

INSERT INTO [DataWarehouse_PIM].[dbo].[PIM_ProductCodesReservation]
SELECT PIM_AllProductCodes.ProductCode,
	0 AS IsReserved
FROM [DataWarehouse_PIM].[dbo].[PIM_AllProductCodes] PIM_AllProductCodes
	LEFT JOIN [DataWarehouse_PIM].[dbo].[PIM_ProductCodesReservation] PIM_ProductCodesReservation
		ON PIM_AllProductCodes.ProductCode = PIM_ProductCodesReservation.ProductCode
WHERE PIM_ProductCodesReservation.ProductCode is null