USE [DataWarehouse_PIM]
GO
/****** Object:  StoredProcedure [dbo].[spd_IDW_SelectProductAssetsResource_CA]    Script Date: 2016-05-02 3:34:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





































-- =============================================
-- Author:		Vianney Rebetez, Junjie Tang
-- Create date: 2016-04-12
-- Description:	PIM Product IDW Report (Product Assets Resource Info)
-- =============================================
ALTER PROCEDURE [dbo].[spd_IDW_SelectProductAssetsResource_CA]
	-- Add the parameters for the stored procedure here
	@CompanyCode VARCHAR(2)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Parameters validations
	IF @CompanyCode NOT IN ('16')
	BEGIN
		RAISERROR('Invalid parameter { %s }: acceptable value is 16.', 16, 1, @CompanyCode)
		RETURN -1
	END

    -- Insert statements for procedure here
	SELECT DISTINCT AssetLibraryDirectory
	,	SourceFileName
	,	TargetFileName
	FROM (SELECT prd.ProductID
          ,    LEFT(asslib.AssetLibraryPath, CHARINDEX('/', asslib.AssetLibraryPath) - 1) AS AssetLibraryDirectory
          ,    RIGHT(asslib.AssetLibraryPath, LEN(asslib.AssetLibraryPath) - CHARINDEX('/', asslib.AssetLibraryPath)) AS SourceFileName
          ,    REPLACE(REPLACE(REPLACE(CASE ISNULL(ass.AssetLongName, '') WHEN '' THEN ass.AssetName ELSE ass.AssetLongName END + LOWER(RIGHT(ass.AssetFilename, 4)),'/','_'), ',', '_'),' ','_') AS TargetFileName
		  ,	   prcass.AssetID
		  ,    prd.SupersededByProductCode
		  ,	   prd.ProductStatus
		  ,	   prc.IsOEMBrand
		  ,	   prd.ProductIsOEM
		  ,	   prc.LastSoldDate
		  ,	   prc.CurrentListPrice
		  ,	   prc.TradeListName
		  ,	   iih.MarketSegment AS InfofloMarketSegment
		  ,	   mh.MarketSegment AS MarketingMarketSegment
		  ,	   prc.CompanyCode
          FROM dbo.ProductCompanyView AS prc 
              LEFT JOIN dbo.ProductView AS prd 
			      ON prd.ProductID = prc.ProductID 
              LEFT JOIN dbo.ProductCompanyAssetView AS prcass 
                  ON prcass.ProductCompanyID = prc.ProductCompanyID 
                  AND prcass.AssetType in ('Brochure','InformationBulletin','InstallationSheet','TechnicalManual','Terms&Conditions')
              LEFT JOIN dbo.AssetView AS ass 
                  ON ass.AssetID = prcass.AssetID 
              LEFT JOIN dbo.AssetLibraryView AS asslib 
                  ON asslib.AssetID = ass.AssetID AND asslib.AssetPushQueue = 'Main Asset Push Queue'
              LEFT JOIN InfofloHierarchyView iih 
                  ON iih.ProductLineID = prd.ProductLineID 
              LEFT JOIN MarketingHierarchyView mh 
                  ON mh.ProductLineID = prc.ProductLineID 
              
          UNION
       
          SELECT prd.ProductID
          ,    LEFT(asslib.AssetLibraryPath, CHARINDEX('/', asslib.AssetLibraryPath) - 1) AS AssetLibraryDirectory
          ,    RIGHT(asslib.AssetLibraryPath, LEN(asslib.AssetLibraryPath) - CHARINDEX('/', asslib.AssetLibraryPath)) AS SourceFileName
          ,    REPLACE(REPLACE(REPLACE(CASE ISNULL(ass.AssetLongName, '') WHEN '' THEN ass.AssetName ELSE ass.AssetLongName END + LOWER(RIGHT(ass.AssetFilename, 4)),'/','_'), ',', '_'),' ','_') AS TargetFileName
		  ,	   prcass.AssetID
		  ,    prd.SupersededByProductCode
		  ,	   prd.ProductStatus
		  ,	   prc.IsOEMBrand
		  ,	   prd.ProductIsOEM
		  ,	   prc.LastSoldDate
		  ,	   prc.CurrentListPrice
		  ,	   prc.TradeListName
		  ,	   iih.MarketSegment AS InfofloMarketSegment
		  ,	   mh.MarketSegment AS MarketingMarketSegment
		  ,	   prc.CompanyCode
          FROM dbo.ProductCompanyView AS prc 
              LEFT JOIN dbo.ProductView AS prd 
                  ON prd.ProductID = prc.ProductID 
              LEFT JOIN dbo.ProductCompanyAssetViewFrench AS prcass 
                  ON prcass.ProductCompanyID = prc.ProductCompanyID 
                  AND prcass.AssetType in ('Brochure','InformationBulletin','InstallationSheet','TechnicalManual','Terms&Conditions')
              LEFT JOIN dbo.AssetView AS ass 
                  ON ass.AssetID = prcass.AssetID 
              LEFT JOIN dbo.AssetLibraryView AS asslib 
                  ON asslib.AssetID = ass.AssetID 
                  AND asslib.AssetPushQueue = 'Main Asset Push Queue'
              LEFT JOIN InfofloHierarchyView iih 
                  ON iih.ProductLineID = prd.ProductLineID 
              LEFT JOIN MarketingHierarchyView mh 
                  ON mh.ProductLineID = prc.ProductLineID 
                          
          UNION
       
          SELECT prd.ProductID
          ,    LEFT(asslib.AssetLibraryPath, CHARINDEX('/', asslib.AssetLibraryPath) - 1) AS AssetLibraryDirectory
          ,    RIGHT(asslib.AssetLibraryPath, LEN(asslib.AssetLibraryPath) - CHARINDEX('/', asslib.AssetLibraryPath)) AS SourceFileName
          ,    REPLACE(REPLACE(REPLACE(CASE ISNULL(ass.AssetLongName, '') WHEN '' THEN ass.AssetName ELSE ass.AssetLongName END + LOWER(RIGHT(ass.AssetFilename, 4)),'/','_'), ',', '_'),' ','_') AS TargetFileName
		  ,	   prdass.AssetID
		  ,    prd.SupersededByProductCode
		  ,	   prd.ProductStatus
		  ,	   prc.IsOEMBrand
		  ,	   prd.ProductIsOEM
		  ,	   prc.LastSoldDate
		  ,	   prc.CurrentListPrice
		  ,	   prc.TradeListName
		  ,	   iih.MarketSegment AS InfofloMarketSegment
		  ,	   mh.MarketSegment AS MarketingMarketSegment
		  ,	   prc.CompanyCode
          FROM dbo.ProductCompanyView AS prc 
              LEFT JOIN dbo.ProductView AS prd 
                  ON prd.ProductID = prc.ProductID 
              LEFT JOIN dbo.ProductAssetView AS prdass 
                  ON prdass.ProductID = prd.ProductID 
                  AND prdass.AssetType = 'MSDS' 
                  AND prdass.AssetLevel = 'Product' 
              LEFT JOIN dbo.AssetView AS ass 
                  ON ass.AssetID = prdass.AssetID 
              LEFT JOIN dbo.AssetLibraryView AS asslib 
                  ON asslib.AssetID = ass.AssetID AND asslib.AssetPushQueue = 'Main Asset Push Queue'
              LEFT JOIN InfofloHierarchyView iih 
                  ON iih.ProductLineID = prd.ProductLineID 
              LEFT JOIN MarketingHierarchyView mh 
                  ON mh.ProductLineID = prc.ProductLineID 
       
          UNION
                          
          SELECT prd.ProductID
          ,    LEFT(asslib.AssetLibraryPath, CHARINDEX('/', asslib.AssetLibraryPath) - 1) AS AssetLibraryDirectory
          ,    RIGHT(asslib.AssetLibraryPath, LEN(asslib.AssetLibraryPath) - CHARINDEX('/', asslib.AssetLibraryPath)) AS SourceFileName
          ,    REPLACE(REPLACE(REPLACE(CASE ISNULL(ass.AssetLongName, '') WHEN '' THEN ass.AssetName ELSE ass.AssetLongName END + LOWER(RIGHT(ass.AssetFilename, 4)),'/','_'), ',', '_'),' ','_') AS TargetFileName
		  ,	   prdass.AssetID
		  ,    prd.SupersededByProductCode
		  ,	   prd.ProductStatus
		  ,	   prc.IsOEMBrand
		  ,	   prd.ProductIsOEM
		  ,	   prc.LastSoldDate
		  ,	   prc.CurrentListPrice
		  ,	   prc.TradeListName
		  ,	   iih.MarketSegment AS InfofloMarketSegment
		  ,	   mh.MarketSegment AS MarketingMarketSegment
		  ,	   prc.CompanyCode
          FROM dbo.ProductCompanyView AS prc 
              LEFT JOIN dbo.ProductView AS prd 
                  ON prd.ProductID = prc.ProductID 
              LEFT JOIN dbo.ProductAssetViewFrench AS prdass 
                  ON prdass.ProductID = prd.ProductID 
                  AND prdass.AssetType = 'MSDS'
                  AND prdass.AssetLevel = 'Product' 
              LEFT JOIN dbo.AssetView AS ass 
                  ON ass.AssetID = prdass.AssetID 
              LEFT JOIN dbo.AssetLibraryView AS asslib 
                  ON asslib.AssetID = ass.AssetID 
                  AND asslib.AssetPushQueue = 'Main Asset Push Queue'
              LEFT JOIN InfofloHierarchyView iih 
                  ON iih.ProductLineID = prd.ProductLineID 
              LEFT JOIN MarketingHierarchyView mh 
                  ON mh.ProductLineID = prc.ProductLineID 
       
          UNION
                          
          SELECT prd.ProductID
          ,    LEFT(asslib.AssetLibraryPath, CHARINDEX('/', asslib.AssetLibraryPath) - 1) AS AssetLibraryDirectory
          ,    RIGHT(asslib.AssetLibraryPath, LEN(asslib.AssetLibraryPath) - CHARINDEX('/', asslib.AssetLibraryPath)) AS SourceFileName
          ,    REPLACE(REPLACE(REPLACE(CASE ISNULL(ass.AssetLongName, '') WHEN '' THEN ass.AssetName ELSE ass.AssetLongName END + LOWER(RIGHT(ass.AssetFilename, 4)),'/','_'), ',', '_'),' ','_') AS TargetFileName
		  ,	   prdass.AssetID
		  ,    prd.SupersededByProductCode
		  ,	   prd.ProductStatus
		  ,	   prc.IsOEMBrand
		  ,	   prd.ProductIsOEM
		  ,	   prc.LastSoldDate
		  ,	   prc.CurrentListPrice
		  ,	   prc.TradeListName
		  ,	   iih.MarketSegment AS InfofloMarketSegment
		  ,	   mh.MarketSegment AS MarketingMarketSegment
		  ,	   prc.CompanyCode
          FROM dbo.ProductCompanyView AS prc 
             LEFT JOIN dbo.ProductView AS prd 
                 ON prd.ProductID = prc.ProductID 
             LEFT JOIN dbo.ProductAssetView AS prdass 
                 ON prdass.ProductID = prd.ProductID 
                 AND prdass.AssetType = 'PrimaryProductImage' 
                 AND prdass.AssetLevel = 'Product' 
             LEFT JOIN dbo.AssetView AS ass 
                 ON ass.AssetID = prdass.AssetID 
             LEFT JOIN dbo.AssetLibraryView AS asslib 
                 ON asslib.AssetID = ass.AssetID 
                 AND asslib.AssetPushQueue = 'Main Asset Push Queue'
                 AND asslib.AssetPushConfiguration in ('IDW Digital Images','IDW Thumbnails')
             LEFT JOIN InfofloHierarchyView iih 
                 ON iih.ProductLineID = prd.ProductLineID 
             LEFT JOIN MarketingHierarchyView mh 
                 ON mh.ProductLineID = prc.ProductLineID 
       
          UNION
                          
          SELECT prd.ProductID
          ,    LEFT(asslib.AssetLibraryPath, CHARINDEX('/', asslib.AssetLibraryPath) - 1) AS AssetLibraryDirectory
          ,    RIGHT(asslib.AssetLibraryPath, LEN(asslib.AssetLibraryPath) - CHARINDEX('/', asslib.AssetLibraryPath)) AS SourceFileName
          ,    REPLACE(REPLACE(REPLACE(CASE ISNULL(ass.AssetLongName, '') WHEN '' THEN ass.AssetName ELSE ass.AssetLongName END + LOWER(RIGHT(ass.AssetFilename, 4)),'/','_'), ',', '_'),' ','_') AS TargetFileName
		  ,	   prdass.AssetID
		  ,    prd.SupersededByProductCode
		  ,	   prd.ProductStatus
		  ,	   prc.IsOEMBrand
		  ,	   prd.ProductIsOEM
		  ,	   prc.LastSoldDate
		  ,	   prc.CurrentListPrice
		  ,	   prc.TradeListName
		  ,	   iih.MarketSegment AS InfofloMarketSegment
		  ,	   mh.MarketSegment AS MarketingMarketSegment
		  ,	   prc.CompanyCode
          FROM dbo.ProductCompanyView AS prc 
              LEFT JOIN dbo.ProductView AS prd 
                  ON prd.ProductID = prc.ProductID 
              LEFT JOIN dbo.ProductAssetView AS prdass 
                  ON prdass.ProductID = prd.ProductID 
                  AND prdass.AssetType = 'MSDS'
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
              LEFT JOIN InfofloHierarchyView iih 
                  ON iih.ProductLineID = prd.ProductLineID 
              LEFT JOIN MarketingHierarchyView mh 
                  ON mh.ProductLineID = prc.ProductLineID 
       
          UNION
                    
          SELECT prd.ProductID
          ,    LEFT(asslib.AssetLibraryPath, CHARINDEX('/', asslib.AssetLibraryPath) - 1) AS AssetLibraryDirectory
          ,    RIGHT(asslib.AssetLibraryPath, LEN(asslib.AssetLibraryPath) - CHARINDEX('/', asslib.AssetLibraryPath)) AS SourceFileName
          ,    REPLACE(REPLACE(REPLACE(CASE ISNULL(ass.AssetLongName, '') WHEN '' THEN ass.AssetName ELSE ass.AssetLongName END + LOWER(RIGHT(ass.AssetFilename, 4)),'/','_'), ',', '_'),' ','_') AS TargetFileName
		  ,	   prdass.AssetID
		  ,    prd.SupersededByProductCode
		  ,	   prd.ProductStatus
		  ,	   prc.IsOEMBrand
		  ,	   prd.ProductIsOEM
		  ,	   prc.LastSoldDate
		  ,	   prc.CurrentListPrice
		  ,	   prc.TradeListName
		  ,	   iih.MarketSegment AS InfofloMarketSegment
		  ,	   mh.MarketSegment AS MarketingMarketSegment
		  ,	   prc.CompanyCode
          FROM dbo.ProductCompanyView AS prc 
              LEFT JOIN dbo.ProductView AS prd 
                  ON prd.ProductID = prc.ProductID 
              LEFT JOIN dbo.ProductAssetViewFrench AS prdass 
                  ON prdass.ProductID = prd.ProductID 
                  AND prdass.AssetType = 'MSDS'
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
              LEFT JOIN InfofloHierarchyView iih 
                  ON iih.ProductLineID = prd.ProductLineID 
              LEFT JOIN MarketingHierarchyView mh 
                  ON mh.ProductLineID = prc.ProductLineID 
       
          UNION
                          
          SELECT prd.ProductID
		  ,    LEFT(asslib.AssetLibraryPath, CHARINDEX('/', asslib.AssetLibraryPath) - 1) AS AssetLibraryDirectory
          ,    RIGHT(asslib.AssetLibraryPath, LEN(asslib.AssetLibraryPath) - CHARINDEX('/', asslib.AssetLibraryPath)) AS SourceFileName
          ,    REPLACE(REPLACE(REPLACE(CASE ISNULL(ass.AssetLongName, '') WHEN '' THEN ass.AssetName ELSE ass.AssetLongName END + LOWER(RIGHT(ass.AssetFilename, 4)),'/','_'), ',', '_'),' ','_') AS TargetFileName
		  ,	   prsass.AssetID
		  ,    prd.SupersededByProductCode
		  ,	   prd.ProductStatus
		  ,	   prc.IsOEMBrand
		  ,	   prd.ProductIsOEM
		  ,	   prc.LastSoldDate
		  ,	   prc.CurrentListPrice
		  ,	   prc.TradeListName
		  ,	   iih.MarketSegment AS InfofloMarketSegment
		  ,	   mh.MarketSegment AS MarketingMarketSegment
		  ,	   prc.CompanyCode
          FROM dbo.ProductCompanyView AS prc 
              LEFT JOIN dbo.ProductView AS prd 
                  ON prd.ProductID = prc.ProductID 
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
              LEFT JOIN InfofloHierarchyView iih 
                  ON iih.ProductLineID = prd.ProductLineID 
              LEFT JOIN MarketingHierarchyView mh 
                  ON mh.ProductLineID = prc.ProductLineID 
	) ProductAssets
    WHERE  ProductAssets.ProductID IS NOT NULL
    AND ProductAssets.AssetID IS NOT NULL
    AND ProductAssets.CompanyCode = @CompanyCode
    AND ISNULL(ProductAssets.SupersededByProductCode, '') = '' 
	AND ProductAssets.ProductStatus in ('New','Regular','No Longer Replenished')
	AND ISNULL(ProductAssets.IsOEMBrand, 'No') = 'No' 
	AND ISNULL(ProductAssets.ProductIsOEM, 'No') = 'No' 
	AND ISNULL(ProductAssets.LastSoldDate,GETDATE()) > DATEADD(YEAR, -3, GetDate())
    AND ProductAssets.CurrentListPrice IS NOT NULL
	AND ProductAssets.TradeListName IS NOT NULL
	AND (LEFT(ProductAssets.InfofloMarketSegment, 1) = '3' OR ISNULL(ProductAssets.MarketingMarketSegment,'') = 'ELECTRICAL')
	ORDER BY AssetLibraryDirectory
	,	SourceFileName
	,	TargetFileName
		

END





































