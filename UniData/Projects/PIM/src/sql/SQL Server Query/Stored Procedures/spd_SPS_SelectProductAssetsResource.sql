USE [DataWarehouse_PIM]
GO
/****** Object:  StoredProcedure [dbo].[spd_SPS_SelectProductAssetsResource]    Script Date: 2016-05-02 3:34:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







































-- =============================================
-- Author:		Vianney Rebetez, Junjie Tang
-- Create date: 2016-04-12
-- Description:	PIM Product: SPS Assets Resource
-- =============================================
ALTER PROCEDURE [dbo].[spd_SPS_SelectProductAssetsResource]
	-- Add the parameters for the stored procedure here
	@CompanyCode VARCHAR(2)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF @CompanyCode NOT IN ('02')
	BEGIN
		RAISERROR('Invalid parameter { %s }: acceptable value is 02.', 16, 1, @CompanyCode)
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
		  ,	   iih.ProductGroup
		  ,	   prc.CompanyCode
          FROM dbo.ProductCompanyView AS prc 
              LEFT JOIN dbo.ProductView AS prd 
			      ON prd.ProductID = prc.ProductID 
              LEFT JOIN dbo.ProductCompanyAssetView AS prcass 
                  ON prcass.ProductCompanyID = prc.ProductCompanyID 
                  AND prcass.AssetType in ('InstallationSheet','Terms&Conditions')
              LEFT JOIN dbo.AssetView AS ass 
                  ON ass.AssetID = prcass.AssetID 
              LEFT JOIN dbo.AssetLibraryView AS asslib 
                  ON asslib.AssetID = ass.AssetID AND asslib.AssetPushQueue = 'Main Asset Push Queue'
              LEFT JOIN InfofloHierarchyView iih 
                  ON iih.ProductLineID = prd.ProductLineID 
                          
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
		  ,	   iih.ProductGroup
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
		  ,	   iih.ProductGroup
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
                 AND asslib.AssetPushConfiguration in ('Product Images (IPEX Std)','IDW Thumbnails')
             LEFT JOIN InfofloHierarchyView iih 
                 ON iih.ProductLineID = prd.ProductLineID 
       
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
		  ,	   iih.ProductGroup
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
	and isnull(left(ProductAssets.ProductGroup,4),'') in ('2167','2172','2202','2271','2273')
	ORDER BY AssetLibraryDirectory
	,	SourceFileName
	,	TargetFileName
		

END







































