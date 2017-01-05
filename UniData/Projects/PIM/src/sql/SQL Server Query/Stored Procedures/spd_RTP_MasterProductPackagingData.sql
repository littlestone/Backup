USE [DataWarehouse_PIM]
GO
/****** Object:  StoredProcedure [dbo].[spd_RTP_MasterProductPackagingData]    Script Date: 2016-05-02 3:34:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





















-- =============================================
-- Author:		Vianney Rebetez, Junjie Tang
-- Create date: 2016-04-27
-- Description:	PIM Master Product Data Report (Packaging Info)
-- =============================================
ALTER PROCEDURE [dbo].[spd_RTP_MasterProductPackagingData]
	-- Add the parameters for the stored procedure here
	@CompanyCode VARCHAR(2),
	@MarketSegment VARCHAR(50),
	@ExcludeOEMProduct VARCHAR(3),
	@ExcludeSuperseededProduct VARCHAR(3),
	@ExcludeProductWithoutPrice VARCHAR(3),
	@ExcludeProductNotSoldSince VARCHAR(3),
	@IncludeNewProductCreatedSince VARCHAR(3),
	@IncludeProductObsoleteSince VARCHAR(3)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Parameters validations
	IF (@CompanyCode NOT IN ('01', '02', '03', '16'))
	BEGIN
		RAISERROR('Invalid parameter { %s }: acceptable value are 01, 02, 03 and 16.', 16, 1, @CompanyCode)
		RETURN -1
	END
	IF @ExcludeProductNotSoldSince = 'N/A' SET @ExcludeProductNotSoldSince = 0
	IF @IncludeNewProductCreatedSince = 'N/A' SET @IncludeNewProductCreatedSince = 0
	IF @IncludeProductObsoleteSince = 'N/A' SET @IncludeProductObsoleteSince = 0

    -- Insert statements for procedure here
	SELECT DISTINCT prd.ProductCode
	,	RTRIM(STR(prd.Length, 10, 3)) AS [LENGTH (in)]
	,	RTRIM(STR(prd.Width, 10, 3)) AS [WIDTH (in)]
	,	RTRIM(STR(prd.Height, 10, 3)) AS [HEIGHT (in)]
	,	RTRIM(STR(prd.ShippingWeight, 10, 3)) AS [WEIGHT (kg)]
	,	prdpck.I2OF5 AS [PK1 I2of5]
	,	RTRIM(STR(prdpck.Quantity, 10, 3)) AS [PK1 QTY]
	,	pc1.PackageCode AS [PK1 CODE]
	,	pc1.PackageType AS [PK1 TYPE]
	,	RTRIM(STR(prdpck.[Length], 10, 3)) AS [PK1 LENGTH (in)]
	,	RTRIM(STR(prdpck.[Width], 10, 3)) AS [PK1 WIDTH (in)]
	,	RTRIM(STR(prdpck.Height, 10, 3)) AS [PK1 HEIGHT (in)]
	,	RTRIM(STR(prdpck.[Weight], 10, 3)) AS [PK1 WEIGHT (kg)]
	,	RTRIM(STR(CAST(prd.ShippingWeight AS float) * CAST(prdpck.Quantity AS float) + CAST(prdpck.[Weight] AS float), 10, 3)) AS [PK1 GROSS WEIGHT (kg)]
	,	pck2.I2OF5 AS [PK2 I2of5]
	,	RTRIM(STR(pck2.Quantity, 10, 3)) AS [PK2 QTY]
	,	RTRIM(STR(CAST(prdpck.Quantity AS float) * CAST(pck2.Quantity AS float), 10, 3)) AS [PK2 PROD QTY]
	,	pc2.PackageCode AS [PK2 CODE]
	,	pc2.PackageType AS [PK2 TYPE]
	,	RTRIM(STR(pck2.[Length], 10, 3)) AS [PK2 LENGTH (in)]
	,	RTRIM(STR(pck2.[Width], 10, 3)) AS [PK2 WIDTH (in)]
	,	RTRIM(STR(CASE ISNULL(pc2.PackageType,'')
			WHEN 'PALLETS' THEN 
				CASE cast(pck2.Width as float)*cast(pck2.[Length] as float)*cast(prdpck.Width as float)*cast(prdpck.[Length] as float)
				WHEN 0 THEN pck2.Height
				ELSE cast(pck2.Height as float) + cast(prdpck.Height as float) * ceiling(cast(pck2.Quantity as float) / (select max(z.x) from (select floor((cast(pck2.Width as float)*cast(pck2.[Length] as float))/(cast(prdpck.Width as float)*cast(prdpck.[Length] as float))) as x union select 1 as x) z))
				END
			ELSE pck2.Height END
		, 10, 3)) AS [PK2 HEIGHT (in)]
	,	RTRIM(STR(pck2.[Weight], 10, 3)) AS [PK2 WEIGHT (kg)]
	,	RTRIM(STR((CAST(prd.ShippingWeight AS float) * CAST(prdpck.Quantity AS float) + CAST(prdpck.[Weight] AS float)) * CAST(pck2.Quantity AS float) + CAST(pck2.[Weight] AS float), 10, 3)) AS [PK2 GROSS WEIGHT (kg)]
	,	pck3.I2OF5 AS [PK3 I2of5]
	,	RTRIM(STR(pck3.Quantity, 10, 3)) AS [PK3 QTY]
	,	RTRIM(STR(CAST(prdpck.Quantity AS float) * CAST(pck2.Quantity AS float) * CAST(pck3.Quantity AS float), 10, 3)) AS [PK3 PROD QTY]
	,	pc3.PackageCode AS [PK3 CODE]
	,	pc3.PackageType AS [PK3 TYPE]
	,	RTRIM(STR(pck3.[Length], 10, 3)) AS [PK3 LENGTH (in)]
	,	RTRIM(STR(pck3.[Width], 10, 3)) AS [PK3 WIDTH (in)]
	,	RTRIM(STR(CASE ISNULL(pc3.PackageType,'')
			WHEN 'PALLETS' THEN 
				CASE cast(pck3.Width as float)*cast(pck3.[Length] as float)*cast(pck2.Width as float)*cast(pck2.[Length] as float)
				WHEN 0 THEN pck3.Height
				ELSE cast(pck3.Height as float) + cast(pck2.Height as float) * ceiling(cast(pck3.Quantity as float) / (select max(z.x) from (select floor((cast(pck3.Width as float)*cast(pck3.[Length] as float))/(cast(pck2.Width as float)*cast(pck2.[Length] as float))) as x union select 1 as x) z))
				END
			ELSE pck3.Height
			END 
		, 10, 3)) AS [PK3 HEIGHT (in)]
	,	RTRIM(STR(pck3.[Weight], 10, 3)) AS [PK3 WEIGHT (kg)]
	,	RTRIM(STR((CAST(prd.ShippingWeight AS float) * CAST(prdpck.Quantity AS float) + CAST(prdpck.[Weight] AS float) * CAST(pck2.Quantity AS float) + CAST(pck2.[Weight] AS float)) * CAST(pck3.Quantity AS float) + CAST(pck3.[Weight] AS float), 10, 3)) AS [PK3 GROSS WEIGHT (kg)]
	,	pck4.I2OF5 AS [PK4 I2of5]
	,	RTRIM(STR(pck4.Quantity, 10, 3)) AS [PK4 QTY]
	,	RTRIM(STR(CAST(prdpck.Quantity AS float) * CAST(pck2.Quantity AS float) * CAST(pck3.Quantity AS float) * CAST(pck4.Quantity AS float), 10, 3)) AS [PK4 PROD QTY]
	,	pc4.PackageCode AS [PK4 CODE]
	,	pc4.PackageType AS [PK4 TYPE]
	,	RTRIM(STR(pck4.[Length], 10, 3)) AS [PK4 LENGTH (in)]
	,	RTRIM(STR(pck4.[Width], 10, 3)) AS [PK4 WIDTH (in)]
	,	RTRIM(STR(CASE ISNULL(pc4.PackageType,'')
			WHEN 'PALLETS' THEN 
				CASE cast(pck4.Width as float)*cast(pck4.[Length] as float)*cast(pck3.Width as float)*cast(pck3.[Length] as float)
				WHEN 0 THEN pck4.Height
				ELSE cast(pck4.Height as float) + cast(pck3.Height as float) * ceiling(cast(pck4.Quantity as float) / (select max(z.x) from (select floor((cast(pck4.Width as float)*cast(pck4.[Length] as float))/(cast(pck3.Width as float)*cast(pck3.[Length] as float))) as x union select 1 as x) z))
				END
			ELSE pck4.Height
			END 
		, 10, 3)) AS [PK4 HEIGHT (in)]
	,	RTRIM(STR(CASE CAST(pck4.[Weight] AS float) WHEN 0 THEN pc4.[Weight] ELSE pck4.[Weight] END, 10, 3)) AS [PK4 WEIGHT (kg)]
	,	RTRIM(STR((((CAST(prd.ShippingWeight AS float) * CAST(prdpck.Quantity AS float) + CAST(prdpck.[Weight] AS float)) * CAST(pck2.Quantity AS float) + CAST(pck2.[Weight] AS float)) * CAST(pck3.Quantity AS float) + CAST(pck3.[Weight] AS float)) * CAST(pck4.Quantity AS float) + CAST(pck4.[Weight] AS float), 10, 3)) AS [PK4 GROSS WEIGHT (kg)]
	,	pck5.I2OF5 AS [PK5 I2of5]
	,	RTRIM(STR(pck5.Quantity, 10, 3)) AS [PK5 QTY]
	,	RTRIM(STR(CAST(prdpck.Quantity AS float) * CAST(pck2.Quantity AS float) * CAST(pck3.Quantity AS float) * CAST(pck4.Quantity AS float) * CAST(pck5.Quantity AS float), 10, 3)) AS [PK5 PROD QTY]
	,	pc5.PackageCode AS [PK5 CODE]
	,	pc5.PackageType AS [PK5 TYPE]
	,	RTRIM(STR(pck5.[Length], 10, 3)) AS [PK5 LENGTH (in)]
	,	RTRIM(STR(pck5.[Width], 10, 3)) AS [PK5 WIDTH (in)]
	,	RTRIM(STR(CASE ISNULL(pc5.PackageType,'')
			WHEN 'PALLETS' THEN 
				CASE cast(pck5.Width as float)*cast(pck5.[Length] as float)*cast(pck4.Width as float)*cast(pck4.[Length] as float)
				WHEN 0 THEN pck5.Height
				ELSE cast(pck5.Height as float) + cast(pck4.Height as float) * ceiling(cast(pck5.Quantity as float) / (select max(z.x) from (select floor((cast(pck5.Width as float)*cast(pck5.[Length] as float))/(cast(pck4.Width as float)*cast(pck4.[Length] as float))) as x union select 1 as x) z))
				END
			ELSE pck5.Height
			END 
		, 10, 3)) AS [PK5 HEIGHT (in)]
	,	RTRIM(STR(pck5.[Weight], 10, 3)) AS [PK5 WEIGHT (kg)]
	,	RTRIM(STR(((((CAST(prd.ShippingWeight AS float) * CAST(prdpck.Quantity AS float) + CAST(prdpck.[Weight] AS float)) * CAST(pck2.Quantity AS float) + CAST(pck2.[Weight] AS float)) * CAST(pck3.Quantity AS float) + CAST(pck3.[Weight] AS float)) * CAST(pck4.Quantity AS float) + CAST(pck4.[Weight] AS float)) * CAST(pck5.Quantity AS float) + CAST(pck5.[Weight] AS float), 10, 3)) AS [PK5 GROSS WEIGHT (kg)]
	FROM dbo.ProductCompanyView AS prc 
		LEFT JOIN dbo.ProductView AS prd 
			ON prd.ProductID = prc.ProductID 
		LEFT JOIN InfofloHierarchyView iih 
			ON iih.ProductLineID = prd.ProductLineID
		LEFT JOIN dbo.PackageView AS prdpck 
			ON prdpck.ChildID = prd.ProductID 
			AND prdpck.IsDefaultBranch = 'Yes' 
		LEFT JOIN dbo.PackageCodeView AS pc1 
			ON pc1.PackageCodeID = prdpck.PackageCodeID 
		LEFT JOIN dbo.PackageView AS pck2 
			ON pck2.ChildID = prdpck.PackageID 
		LEFT JOIN dbo.PackageCodeView AS pc2 
			ON pc2.PackageCodeID = pck2.PackageCodeID 
		LEFT JOIN dbo.PackageView AS pck3 
			ON pck3.ChildID = pck2.PackageID 
		LEFT JOIN dbo.PackageCodeView AS pc3 
			ON pc3.PackageCodeID = pck3.PackageCodeID 
		LEFT JOIN dbo.PackageView AS pck4 
			ON pck4.ChildID = pck3.PackageID 
		LEFT JOIN dbo.PackageCodeView AS pc4 
			ON pc4.PackageCodeID = pck4.PackageCodeID 
		LEFT JOIN dbo.PackageView AS pck5 
			ON pck5.ChildID = pck4.PackageID 
		LEFT JOIN dbo.PackageCodeView AS pc5 
			ON pc5.PackageCodeID = pck5.PackageCodeID
	WHERE prdpck.PackageID IS NOT NULL
	AND prc.CompanyCode = @CompanyCode
	AND (@MarketSegment = 'ALL' OR RIGHT(iih.MarketSegment, LEN(iih.MarketSegment) - CHARINDEX(' - ', iih.MarketSegment) - 2) = @MarketSegment)
	AND (@ExcludeOEMProduct <> 'Yes' OR (ISNULL(prd.ProductIsOEM, 'No') = 'No' AND ISNULL(prc.IsOEMBrand, 'No') = 'No'))
	AND (@ExcludeSuperseededProduct <> 'Yes' OR ISNULL(prd.[SupersededByProductCode], '') = '') 
	AND (@ExcludeProductWithoutPrice <> 'Yes' OR (ISNULL(prc.TradeListName,'') <> '' AND ISNULL(prc.CurrentListPrice,'')<>''))
	AND (prd.ProductStatus IN ('New','Regular','No Longer Replenished')
		 OR (prd.ProductStatus = 'Obsolete' AND @IncludeProductObsoleteSince <> '0' AND (@IncludeProductObsoleteSince = 'ALL' or ISNULL(prd.ObsolescenceDate, GETDATE()) >= DATEADD(MONTH, -cast(@IncludeProductObsoleteSince AS int), GetDate()))))
	AND (@ExcludeProductNotSoldSince = '0' OR ISNULL(prc.LastSoldDate, GETDATE()) >= DATEADD(YEAR, -CAST(@ExcludeProductNotSoldSince AS int), GetDate()))
	AND (@IncludeNewProductCreatedSince = '0' OR ISNULL(prd.CreationDate, GETDATE()) >= DATEADD(MONTH, -CAST(@IncludeNewProductCreatedSince AS int), GetDate()))
	ORDER BY prd.ProductCode
END









