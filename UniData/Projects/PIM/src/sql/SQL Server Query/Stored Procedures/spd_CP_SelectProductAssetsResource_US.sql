USE [DataWarehouse_PIM]
GO
/****** Object:  StoredProcedure [dbo].[spd_CP_SelectProductAssetsResource_US]    Script Date: 2016-05-02 3:33:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






























-- =============================================
-- Author:		Vianney Rebetez, Junjie Tang
-- Create date: 2016-03-11
-- Description:	PIM Customer Standard Products Report (Product Assets Resource Info)
-- =============================================
ALTER PROCEDURE [dbo].[spd_CP_SelectProductAssetsResource_US]
	-- Add the parameters for the stored procedure here
	@CompanyCode VARCHAR(2)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Parameters validations
	IF @CompanyCode NOT IN ('02', '03')
	BEGIN
		RAISERROR('Invalid parameter { %s }: acceptable value are 02 and 03.', 16, 1, @CompanyCode)
		RETURN -1
	END

    -- Insert statements for procedure here
	SELECT DISTINCT AssetLibraryDirectory
	,	SourceFileName
	,	TargetFileName
	FROM (
		SELECT prd.ProductCode
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
		,	prc.CompanyCode
		FROM dbo.ProductCompanyView AS prc 
			LEFT JOIN dbo.ProductView AS prd 
				ON prd.ProductID = prc.ProductID 
			LEFT JOIN dbo.ProductCompanyAssetView AS prcass 
				ON prcass.ProductCompanyID = prc.ProductCompanyID 
			LEFT JOIN dbo.AssetView AS ass 
				ON ass.AssetID = prcass.AssetID 
			LEFT JOIN dbo.AssetLibraryView AS asslib 
				ON asslib.AssetID = ass.AssetID AND asslib.AssetPushQueue = 'Main Asset Push Queue'
					
		UNION

		SELECT prd.ProductCode
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
		,	prc.CompanyCode
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

		UNION
					
		SELECT prd.ProductCode
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
		,	prc.CompanyCode
		FROM dbo.ProductCompanyView AS prc 
			LEFT JOIN dbo.ProductView AS prd 
				ON prd.ProductID = prc.ProductID
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
		,	prc.CompanyCode
		FROM dbo.ProductCompanyView AS prc 
			LEFT JOIN dbo.ProductView AS prd 
				ON prd.ProductID = prc.ProductID
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
		,	prc.CompanyCode
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
	) ProductAssets
	WHERE ProductAssets.AssetID IS NOT NULL
	AND ProductAssets.CompanyCode = @CompanyCode
	AND ISNULL(ProductAssets.SupersededByProductCode, '') = ''
	AND	ProductAssets.ProductStatus in ('New','Regular','No Longer Replenished')
	AND	ISNULL(ProductAssets.IsOEMBrand, 'No') = 'No'
	AND	ISNULL(ProductAssets.ProductIsOEM, 'No') = 'No'
	AND	(ISNULL(ProductAssets.LastSoldDate,GETDATE()) > DATEADD(YEAR, -3, GetDate()) AND ProductAssets.CurrentListPrice IS NOT NULL AND ProductAssets.TradeListName IS NOT NULL)
	ORDER BY AssetLibraryDirectory
	,	SourceFileName
	,	TargetFileName
		

END






























