USE [DataWarehouse_PIM]
GO
/****** Object:  StoredProcedure [dbo].[spd_TS_SelectProductAssetsResource]    Script Date: 2016-05-02 3:35:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




































-- =============================================
-- Author:		Vianney Rebetez, Junjie Tang
-- Create date: 2016-03-11
-- Description:	PIM Customer Trade Service Report (Product Assets Resource Info)
-- =============================================
ALTER PROCEDURE [dbo].[spd_TS_SelectProductAssetsResource]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT DISTINCT AssetLibraryDirectory
	,	SourceFileName
	,	TargetFileName
	FROM (
		SELECT prd.ProductCode
		,	'EN' AS [Language]
		,	prcass.AssetType
		,	'' AS IsFamilyImage
		,	asslib.AssetLibraryPath
		,   LEFT(asslib.AssetLibraryPath, CHARINDEX('/', asslib.AssetLibraryPath) - 1) AS AssetLibraryDirectory
		,	RIGHT(asslib.AssetLibraryPath, LEN(asslib.AssetLibraryPath) - CHARINDEX('/', asslib.AssetLibraryPath)) AS SourceFileName
		,	REPLACE(REPLACE(REPLACE(CASE ISNULL(ass.AssetLongName, '') WHEN '' THEN ass.AssetName ELSE ass.AssetLongName END + LOWER(RIGHT(ass.AssetFilename, 4)),'/','_'), ',', '_'),' ','_') AS TargetFileName
		,	CASE prcass.AssetLevel WHEN 'Product' THEN 'Product-Company' ELSE prcass.AssetLevel END AS AssetLevel
		,	prcass.AssetID
		,	prd.SupersededByProductCode
		,	prd.ProductStatus
		,	prc.IsOEMBrand
		,	prd.ProductIsOEM
		,	prc.LastSoldDate
		,	prc.CurrentListPrice
		,	prc.CurrentListPriceEffectiveDate
		,	prc.TradeListName
		,	iih.MarketSegment AS InfofloMarketSegment
		,	mh.MarketSegment AS MarketingMarketSegment
		,	prc.CompanyCode
		FROM dbo.ProductCompanyView AS prc 
			LEFT JOIN dbo.ProductView AS prd 
				ON prd.ProductID = prc.ProductID 
		    LEFT JOIN InfofloHierarchyView iih 
				ON iih.ProductLineID = prd.ProductLineID 
			LEFT JOIN MarketingHierarchyView mh 
				ON mh.ProductLineID = prc.ProductLineID 
			LEFT JOIN dbo.ProductCompanyAssetView AS prcass 
				ON prcass.ProductCompanyID = prc.ProductCompanyID 
			LEFT JOIN dbo.AssetView AS ass 
				ON ass.AssetID = prcass.AssetID 
			LEFT JOIN dbo.AssetLibraryView AS asslib 
				ON asslib.AssetID = ass.AssetID AND asslib.AssetPushQueue = 'Main Asset Push Queue'
		
		UNION
		
		SELECT prd.ProductCode
		,	'FR' AS [Language]
		,	prcass.AssetType
		,	'' AS IsFamilyImage
		,	asslib.AssetLibraryPath
		,   LEFT(asslib.AssetLibraryPath, CHARINDEX('/', asslib.AssetLibraryPath) - 1) AS AssetLibraryDirectory
		,	RIGHT(asslib.AssetLibraryPath, LEN(asslib.AssetLibraryPath) - CHARINDEX('/', asslib.AssetLibraryPath)) AS SourceFileName
		,	REPLACE(REPLACE(REPLACE(CASE ISNULL(ass.AssetLongName, '') WHEN '' THEN ass.AssetName ELSE ass.AssetLongName END + LOWER(RIGHT(ass.AssetFilename, 4)),'/','_'), ',', '_'),' ','_') AS TargetFileName
		,	CASE prcass.AssetLevel WHEN 'Product' THEN 'Product-Company' ELSE prcass.AssetLevel END AS AssetLevel
		,	prcass.AssetID
		,	prd.SupersededByProductCode
		,	prd.ProductStatus
		,	prc.IsOEMBrand
		,	prd.ProductIsOEM
		,	prc.LastSoldDate
		,	prc.CurrentListPrice
		,	prc.CurrentListPriceEffectiveDate
		,	prc.TradeListName
		,	iih.MarketSegment AS InfofloMarketSegment
		,	mh.MarketSegment AS MarketingMarketSegment
		,	prc.CompanyCode
		FROM dbo.ProductCompanyView AS prc 
			LEFT JOIN dbo.ProductView AS prd 
				ON prd.ProductID = prc.ProductID
		    LEFT JOIN InfofloHierarchyView iih 
				ON iih.ProductLineID = prd.ProductLineID 
			LEFT JOIN MarketingHierarchyView mh 
				ON mh.ProductLineID = prc.ProductLineID 
			LEFT JOIN dbo.ProductCompanyAssetViewFrench AS prcass 
				ON prcass.ProductCompanyID = prc.ProductCompanyID 
			LEFT JOIN dbo.AssetView AS ass 
				ON ass.AssetID = prcass.AssetID 
			LEFT JOIN dbo.AssetLibraryView AS asslib 
				ON asslib.AssetID = ass.AssetID 
				AND asslib.AssetPushQueue = 'Main Asset Push Queue'
					
		UNION

		SELECT prd.ProductCode
		,	'EN' AS [Language]
		,	'MSDS' AS AssetType
		,	'' AS IsFamilyImage
		,	asslib.AssetLibraryPath
		,   LEFT(asslib.AssetLibraryPath, CHARINDEX('/', asslib.AssetLibraryPath) - 1) AS AssetLibraryDirectory
		,	RIGHT(asslib.AssetLibraryPath, LEN(asslib.AssetLibraryPath) - CHARINDEX('/', asslib.AssetLibraryPath)) AS SourceFileName
		,	REPLACE(REPLACE(REPLACE(CASE ISNULL(ass.AssetLongName, '') WHEN '' THEN ass.AssetName ELSE ass.AssetLongName END + LOWER(RIGHT(ass.AssetFilename, 4)),'/','_'), ',', '_'),' ','_') AS TargetFileName
		,	'Product' AS AssetLevel
		,	prdass.AssetID
		,	prd.SupersededByProductCode
		,	prd.ProductStatus
		,	prc.IsOEMBrand
		,	prd.ProductIsOEM
		,	prc.LastSoldDate
		,	prc.CurrentListPrice
		,	prc.CurrentListPriceEffectiveDate
		,	prc.TradeListName
		,	iih.MarketSegment AS InfofloMarketSegment
		,	mh.MarketSegment AS MarketingMarketSegment
		,	prc.CompanyCode
		FROM dbo.ProductCompanyView AS prc 
			LEFT JOIN dbo.ProductView AS prd 
				ON prd.ProductID = prc.ProductID
		    LEFT JOIN InfofloHierarchyView iih 
				ON iih.ProductLineID = prd.ProductLineID 
			LEFT JOIN MarketingHierarchyView mh 
				ON mh.ProductLineID = prc.ProductLineID 
			LEFT JOIN dbo.ProductAssetView AS prdass 
				ON prdass.ProductID = prd.ProductID 
				AND prdass.AssetType = 'MSDS' 
				AND prdass.AssetLevel = 'Product' 
			LEFT JOIN dbo.AssetView AS ass 
				ON ass.AssetID = prdass.AssetID 
			LEFT JOIN dbo.AssetLibraryView AS asslib 
				ON asslib.AssetID = ass.AssetID AND asslib.AssetPushQueue = 'Main Asset Push Queue'
					
		UNION

		SELECT prd.ProductCode
		,	'FR' AS [Language]
		,	'MSDS' AS AssetType
		,	'' AS IsFamilyImage
		,	asslib.AssetLibraryPath
		,   LEFT(asslib.AssetLibraryPath, CHARINDEX('/', asslib.AssetLibraryPath) - 1) AS AssetLibraryDirectory
		,	RIGHT(asslib.AssetLibraryPath, LEN(asslib.AssetLibraryPath) - CHARINDEX('/', asslib.AssetLibraryPath)) AS SourceFileName
		,	REPLACE(REPLACE(REPLACE(CASE ISNULL(ass.AssetLongName, '') WHEN '' THEN ass.AssetName ELSE ass.AssetLongName END + LOWER(RIGHT(ass.AssetFilename, 4)),'/','_'), ',', '_'),' ','_') AS TargetFileName
		,	'Product' AS AssetLevel
		,	prdass.AssetID
		,	prd.SupersededByProductCode
		,	prd.ProductStatus
		,	prc.IsOEMBrand
		,	prd.ProductIsOEM
		,	prc.LastSoldDate
		,	prc.CurrentListPrice
		,	prc.CurrentListPriceEffectiveDate
		,	prc.TradeListName
		,	iih.MarketSegment AS InfofloMarketSegment
		,	mh.MarketSegment AS MarketingMarketSegment
		,	prc.CompanyCode
		FROM dbo.ProductCompanyView AS prc 
			LEFT JOIN dbo.ProductView AS prd 
				ON prd.ProductID = prc.ProductID
		    LEFT JOIN InfofloHierarchyView iih 
				ON iih.ProductLineID = prd.ProductLineID 
			LEFT JOIN MarketingHierarchyView mh 
				ON mh.ProductLineID = prc.ProductLineID 
			LEFT JOIN dbo.ProductAssetViewFrench AS prdass 
				ON prdass.ProductID = prd.ProductID 
				AND prdass.AssetType = 'MSDS' 
				AND prdass.AssetLevel = 'Product' 
			LEFT JOIN dbo.AssetView AS ass 
				ON ass.AssetID = prdass.AssetID 
			LEFT JOIN dbo.AssetLibraryView AS asslib 
				ON asslib.AssetID = ass.AssetID AND asslib.AssetPushQueue = 'Main Asset Push Queue'
		
		UNION
					
		SELECT prd.ProductCode
		,	'' AS [Language]
		,	'ProductImage' AS AssetType
		,	prdass.IsFamilyImage
		,	asslib.AssetLibraryPath
		,   LEFT(asslib.AssetLibraryPath, CHARINDEX('/', asslib.AssetLibraryPath) - 1) AS AssetLibraryDirectory
		,	RIGHT(asslib.AssetLibraryPath, LEN(asslib.AssetLibraryPath) - CHARINDEX('/', asslib.AssetLibraryPath)) AS SourceFileName
		,	REPLACE(REPLACE(REPLACE(CASE ISNULL(ass.AssetLongName, '') WHEN '' THEN ass.AssetName ELSE ass.AssetLongName END + LOWER(RIGHT(ass.AssetFilename, 4)),'/','_'), ',', '_'),' ','_') AS TargetFileName
		,	'Product' AS AssetLevel
		,	prdass.AssetID
		,	prd.SupersededByProductCode
		,	prd.ProductStatus
		,	prc.IsOEMBrand
		,	prd.ProductIsOEM
		,	prc.LastSoldDate
		,	prc.CurrentListPrice
		,	prc.CurrentListPriceEffectiveDate
		,	prc.TradeListName
		,	iih.MarketSegment AS InfofloMarketSegment
		,	mh.MarketSegment AS MarketingMarketSegment
		,	prc.CompanyCode
		FROM dbo.ProductCompanyView AS prc 
			LEFT JOIN dbo.ProductView AS prd 
				ON prd.ProductID = prc.ProductID
		    LEFT JOIN InfofloHierarchyView iih 
				ON iih.ProductLineID = prd.ProductLineID 
			LEFT JOIN MarketingHierarchyView mh 
				ON mh.ProductLineID = prc.ProductLineID 
			LEFT JOIN dbo.ProductAssetViewFrench AS prdass 
				ON prdass.ProductID = prd.ProductID 
				AND prdass.AssetType = 'PrimaryProductImage' 
				AND prdass.AssetLevel = 'Product' 
			LEFT JOIN dbo.AssetView AS ass 
				ON ass.AssetID = prdass.AssetID 
			LEFT JOIN dbo.AssetLibraryView AS asslib 
				ON asslib.AssetID = ass.AssetID 
				AND asslib.AssetPushQueue = 'Main Asset Push Queue'
				AND asslib.AssetPushConfiguration = 'Product Images (IPEX Std)'
		
		UNION
					
		SELECT prd.ProductCode
		,	'EN' AS [Language]
		,	prdass.AssetType
		,	'' AS IsFamilyImage
		,	asslib.AssetLibraryPath
		,   LEFT(asslib.AssetLibraryPath, CHARINDEX('/', asslib.AssetLibraryPath) - 1) AS AssetLibraryDirectory
		,	RIGHT(asslib.AssetLibraryPath, LEN(asslib.AssetLibraryPath) - CHARINDEX('/', asslib.AssetLibraryPath)) AS SourceFileName
		,	REPLACE(REPLACE(REPLACE(CASE ISNULL(ass.AssetLongName, '') WHEN '' THEN ass.AssetName ELSE ass.AssetLongName END + LOWER(RIGHT(ass.AssetFilename, 4)),'/','_'), ',', '_'),' ','_') AS TargetFileName
		,	'Material' AS AssetLevel
		,	prdass.AssetID
		,	prd.SupersededByProductCode
		,	prd.ProductStatus
		,	prc.IsOEMBrand
		,	prd.ProductIsOEM
		,	prc.LastSoldDate
		,	prc.CurrentListPrice
		,	prc.CurrentListPriceEffectiveDate
		,	prc.TradeListName
		,	iih.MarketSegment AS InfofloMarketSegment
		,	mh.MarketSegment AS MarketingMarketSegment
		,	prc.CompanyCode
		FROM dbo.ProductCompanyView AS prc 
			LEFT JOIN dbo.ProductView AS prd 
				ON prd.ProductID = prc.ProductID
		    LEFT JOIN InfofloHierarchyView iih 
				ON iih.ProductLineID = prd.ProductLineID 
			LEFT JOIN MarketingHierarchyView mh 
				ON mh.ProductLineID = prc.ProductLineID 
			LEFT JOIN dbo.ProductAssetView AS prdass 
				ON prdass.ProductID = prd.ProductID 
				AND prdass.AssetLevel = 'Material' 
			LEFT JOIN (SELECT DISTINCT ProductID + '\' + AssetType AS ID
					   FROM dbo.ProductAssetView
					   WHERE AssetLevel = 'Product') AS X 
				ON X.ID = prdass.ProductID + '\' + prdass.AssetType 
			LEFT JOIN dbo.AssetView AS ass 
				ON ass.AssetID = prdass.AssetID 
			LEFT JOIN dbo.AssetLibraryView AS asslib 
				ON asslib.AssetID = ass.AssetID 
				AND asslib.AssetPushQueue = 'Main Asset Push Queue'
		WHERE X.ID is null
		
		UNION
				
		SELECT prd.ProductCode
		,	'FR' AS [Language]
		,	prdass.AssetType
		,	'' AS IsFamilyImage
		,	asslib.AssetLibraryPath
		,   LEFT(asslib.AssetLibraryPath, CHARINDEX('/', asslib.AssetLibraryPath) - 1) AS AssetLibraryDirectory
		,	RIGHT(asslib.AssetLibraryPath, LEN(asslib.AssetLibraryPath) - CHARINDEX('/', asslib.AssetLibraryPath)) AS SourceFileName
		,	REPLACE(REPLACE(REPLACE(CASE ISNULL(ass.AssetLongName, '') WHEN '' THEN ass.AssetName ELSE ass.AssetLongName END + LOWER(RIGHT(ass.AssetFilename, 4)),'/','_'), ',', '_'),' ','_') AS TargetFileName
		,	'Material' AS AssetLevel
		,	prdass.AssetID
		,	prd.SupersededByProductCode
		,	prd.ProductStatus
		,	prc.IsOEMBrand
		,	prd.ProductIsOEM
		,	prc.LastSoldDate
		,	prc.CurrentListPrice
		,	prc.CurrentListPriceEffectiveDate
		,	prc.TradeListName
		,	iih.MarketSegment AS InfofloMarketSegment
		,	mh.MarketSegment AS MarketingMarketSegment
		,	prc.CompanyCode
		FROM dbo.ProductCompanyView AS prc 
			LEFT JOIN dbo.ProductView AS prd 
				ON prd.ProductID = prc.ProductID
		    LEFT JOIN InfofloHierarchyView iih 
				ON iih.ProductLineID = prd.ProductLineID 
			LEFT JOIN MarketingHierarchyView mh 
				ON mh.ProductLineID = prc.ProductLineID 
			LEFT JOIN dbo.ProductAssetViewFrench AS prdass 
				ON prdass.ProductID = prd.ProductID 
				AND prdass.AssetLevel = 'Material' 
			LEFT JOIN (SELECT DISTINCT ProductID + '\' + AssetType AS ID
					   FROM dbo.ProductAssetView AS ProductAssetView_1
					   WHERE AssetLevel = 'Product') AS Y
				ON Y.ID = prdass.ProductID + '\' + prdass.AssetType 
			LEFT JOIN dbo.AssetView AS ass 
				ON ass.AssetID = prdass.AssetID 
			LEFT JOIN dbo.AssetLibraryView AS asslib 
				ON asslib.AssetID = ass.AssetID 
				AND asslib.AssetPushQueue = 'Main Asset Push Queue'
		WHERE Y.ID is null
		
		UNION
					
		SELECT prd.ProductCode
		,	'' AS [Language]
		,	'2D Drawing' AS AssetType
		,	'' AS IsFamilyImage
		,	asslib.AssetLibraryPath
		,   LEFT(asslib.AssetLibraryPath, CHARINDEX('/', asslib.AssetLibraryPath) - 1) AS AssetLibraryDirectory
		,	RIGHT(asslib.AssetLibraryPath, LEN(asslib.AssetLibraryPath) - CHARINDEX('/', asslib.AssetLibraryPath)) AS SourceFileName
		,	REPLACE(REPLACE(REPLACE(CASE ISNULL(ass.AssetLongName, '') WHEN '' THEN ass.AssetName ELSE ass.AssetLongName END + LOWER(RIGHT(ass.AssetFilename, 4)),'/','_'), ',', '_'),' ','_') AS TargetFileName
		,	'Product-Source' AS AssetLevel
		,	prsass.AssetID
		,	prd.SupersededByProductCode
		,	prd.ProductStatus
		,	prc.IsOEMBrand
		,	prd.ProductIsOEM
		,	prc.LastSoldDate
		,	prc.CurrentListPrice
		,	prc.CurrentListPriceEffectiveDate
		,	prc.TradeListName
		,	iih.MarketSegment AS InfofloMarketSegment
		,	mh.MarketSegment AS MarketingMarketSegment
		,	prc.CompanyCode
		FROM dbo.ProductCompanyView AS prc 
			LEFT JOIN dbo.ProductView AS prd 
				ON prd.ProductID = prc.ProductID
			LEFT JOIN InfofloHierarchyView iih 
				ON iih.ProductLineID = prd.ProductLineID 
			LEFT JOIN MarketingHierarchyView mh 
				ON mh.ProductLineID = prc.ProductLineID 
			LEFT JOIN dbo.ProductSourceView AS prs 
				ON prs.ProductID = prd.ProductID 
			LEFT JOIN dbo.ProductSourceAssetView AS prsass 
				ON prsass.ProductSourceID = prs.ProductSourceID 
				AND prsass.AssetID = ISNULL((SELECT TOP (1) AssetID
											 FROM dbo.ProductSourceAssetView
											 WHERE AssetType = '2D Drawing' 
				AND ProductSourceID = prs.ProductSourceID), 0) 
			LEFT JOIN dbo.AssetView AS ass 
				ON ass.AssetID = prsass.AssetID 
			LEFT JOIN dbo.AssetLibraryView AS asslib 
				ON asslib.AssetID = ass.AssetID 
				AND asslib.AssetPushQueue = 'Main Asset Push Queue'
	) ProductAssets
	WHERE ProductAssets.AssetID IS NOT NULL
	AND ProductAssets.CompanyCode IN ('01', '02', '03', '16')
	AND ISNULL(ProductAssets.SupersededByProductCode, '') = ''
	AND	ProductAssets.ProductStatus in ('New','Regular','No Longer Replenished')
	AND	ISNULL(ProductAssets.IsOEMBrand, 'No') = 'No'
	AND	ISNULL(ProductAssets.ProductIsOEM, 'No') = 'No'
	AND	(ISNULL(ProductAssets.LastSoldDate,GETDATE()) > DATEADD(YEAR, -3, GetDate()) AND ProductAssets.CurrentListPrice IS NOT NULL AND ProductAssets.TradeListName IS NOT NULL)
	AND (LEFT(ProductAssets.InfofloMarketSegment, 1) <> '5' AND ProductAssets.MarketingMarketSegment <> 'MUNICIPAL')
	ORDER BY AssetLibraryDirectory
	,	SourceFileName
	,	TargetFileName
		

END




































