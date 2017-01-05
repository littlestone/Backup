USE [DataWarehouse_PIM]
GO
/****** Object:  StoredProcedure [dbo].[spd_CP_SelectProductAssets_CA]    Script Date: 2016-05-02 3:32:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
























-- =============================================
-- Author:		Vianney Rebetez, Junjie Tang
-- Create date: 2016-03-11
-- Description:	PIM Customer Standard Products Report (Product Assets Info)
-- =============================================
ALTER PROCEDURE [dbo].[spd_CP_SelectProductAssets_CA]
	-- Add the parameters for the stored procedure here
	@CompanyCode VARCHAR(2)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Parameters validations
	IF @CompanyCode NOT IN ('01', '16')
	BEGIN
		RAISERROR('Invalid parameter { %s }: acceptable value are 01 and 16.', 16, 1, @CompanyCode)
		RETURN -1
	END

    -- Insert statements for procedure here
	SELECT Z.* FROM (

	SELECT prd.ProductCode
	,	'EN' AS [Language]
	,	prcass.AssetType
	,	'' AS IsFamilyImage
	,	asslib.AssetLibraryPath
	,	LEFT(asslib.AssetLibraryPath, CHARINDEX('/', asslib.AssetLibraryPath)) + REPLACE(REPLACE(REPLACE(CASE ISNULL(ass.AssetLongName, '') WHEN '' THEN ass.AssetName ELSE ass.AssetLongName END + LOWER(RIGHT(ass.AssetFilename, 4)),'/','_'), ',', '_'),' ','_') AS AssetFilename
	,	CASE prcass.AssetLevel WHEN 'Product' THEN 'Product-Company' ELSE prcass.AssetLevel END AS AssetLevel
	FROM dbo.ProductCompanyView AS prc 
		LEFT JOIN dbo.ProductView AS prd 
			ON prd.ProductID = prc.ProductID 
		LEFT JOIN dbo.ProductCompanyAssetView AS prcass 
			ON prcass.ProductCompanyID = prc.ProductCompanyID 
		LEFT JOIN dbo.AssetView AS ass 
			ON ass.AssetID = prcass.AssetID 
		LEFT JOIN dbo.AssetLibraryView AS asslib 
			ON asslib.AssetID = ass.AssetID AND asslib.AssetPushQueue = 'Main Asset Push Queue'
	WHERE prc.CompanyCode = @CompanyCode
	AND	prcass.AssetID IS NOT NULL
	AND ISNULL(prd.[SupersededByProductCode], '') = ''
	AND	prd.ProductStatus in ('New','Regular','No Longer Replenished')
	AND	ISNULL(prc.IsOEMBrand, 'No') = 'No'
	AND	ISNULL(prd.ProductIsOEM, 'No') = 'No'
	AND	(ISNULL(prc.LastSoldDate,GETDATE()) > DATEADD(YEAR, -3, GetDate()) AND prc.CurrentListPrice IS NOT NULL AND prc.TradeListName IS NOT NULL)
	
	UNION
	
	SELECT prd.ProductCode
	,	'FR' AS [Language]
	,	prcass.AssetType
	,	'' AS IsFamilyImage
	,	asslib.AssetLibraryPath
	,	LEFT(asslib.AssetLibraryPath, CHARINDEX('/', asslib.AssetLibraryPath)) + REPLACE(REPLACE(REPLACE(CASE ISNULL(ass.AssetLongName, '') WHEN '' THEN ass.AssetName ELSE ass.AssetLongName END + LOWER(RIGHT(ass.AssetFilename, 4)),'/','_'), ',', '_'),' ','_') AS AssetFilename
	,	CASE prcass.AssetLevel WHEN 'Product' THEN 'Product-Company' ELSE prcass.AssetLevel END AS AssetLevel
	FROM dbo.ProductCompanyView AS prc 
		LEFT JOIN dbo.ProductView AS prd 
			ON prd.ProductID = prc.ProductID 
		LEFT JOIN dbo.ProductCompanyAssetViewFrench AS prcass 
			ON prcass.ProductCompanyID = prc.ProductCompanyID 
		LEFT JOIN dbo.AssetView AS ass 
			ON ass.AssetID = prcass.AssetID 
		LEFT JOIN dbo.AssetLibraryView AS asslib 
			ON asslib.AssetID = ass.AssetID 
			AND asslib.AssetPushQueue = 'Main Asset Push Queue'
	WHERE prc.CompanyCode = @CompanyCode
	AND	prcass.AssetID IS NOT NULL
	AND ISNULL(prd.[SupersededByProductCode], '') = ''
	AND	prd.ProductStatus in ('New','Regular','No Longer Replenished')
	AND	ISNULL(prc.IsOEMBrand, 'No') = 'No'
	AND	ISNULL(prd.ProductIsOEM, 'No') = 'No'
	AND	(ISNULL(prc.LastSoldDate,GETDATE()) > DATEADD(YEAR, -3, GetDate()) AND prc.CurrentListPrice IS NOT NULL AND prc.TradeListName IS NOT NULL)
				
	UNION
	
	SELECT prd.ProductCode
	,	'EN' AS [Language]
	,	'MSDS' AS AssetType
	,	'' AS IsFamilyImage
	,	asslib.AssetLibraryPath
	,	LEFT(asslib.AssetLibraryPath, CHARINDEX('/', asslib.AssetLibraryPath)) + REPLACE(REPLACE(REPLACE(CASE ISNULL(ass.AssetLongName, '') WHEN '' THEN ass.AssetName ELSE ass.AssetLongName END + LOWER(RIGHT(ass.AssetFilename, 4)),'/','_'), ',', '_'),' ','_') AS AssetFilename
	,	'Product' AS AssetLevel
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
	WHERE prc.CompanyCode = @CompanyCode
	AND	prdass.AssetID IS NOT NULL
	AND ISNULL(prd.[SupersededByProductCode], '') = ''
	AND	prd.ProductStatus in ('New','Regular','No Longer Replenished')
	AND	ISNULL(prc.IsOEMBrand, 'No') = 'No'
	AND	ISNULL(prd.ProductIsOEM, 'No') = 'No'
	AND	(ISNULL(prc.LastSoldDate,GETDATE()) > DATEADD(YEAR, -3, GetDate()) AND prc.CurrentListPrice IS NOT NULL AND prc.TradeListName IS NOT NULL)
	
	UNION
				
	SELECT prd.ProductCode
	,	'FR' AS [Language]
	,	'MSDS' AS AssetType
	,	'' AS IsFamilyImage
	,	asslib.AssetLibraryPath
	,	LEFT(asslib.AssetLibraryPath, CHARINDEX('/', asslib.AssetLibraryPath)) + REPLACE(REPLACE(REPLACE(CASE ISNULL(ass.AssetLongName, '') WHEN '' THEN ass.AssetName ELSE ass.AssetLongName END + LOWER(RIGHT(ass.AssetFilename, 4)),'/','_'), ',', '_'),' ','_') AS AssetFilename
	,	'Product' AS AssetLevel
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
	WHERE prc.CompanyCode = @CompanyCode
	AND	prdass.AssetID IS NOT NULL
	AND ISNULL(prd.[SupersededByProductCode], '') = ''
	AND	prd.ProductStatus in ('New','Regular','No Longer Replenished')
	AND	ISNULL(prc.IsOEMBrand, 'No') = 'No'
	AND	ISNULL(prd.ProductIsOEM, 'No') = 'No'
	AND	(ISNULL(prc.LastSoldDate,GETDATE()) > DATEADD(YEAR, -3, GetDate()) AND prc.CurrentListPrice IS NOT NULL AND prc.TradeListName IS NOT NULL)
	
	UNION
				
	SELECT prd.ProductCode
	,	'' AS [Language]
	,	'ProductImage' AS AssetType
	,	prdass.IsFamilyImage
	,	asslib.AssetLibraryPath
	,	LEFT(asslib.AssetLibraryPath, CHARINDEX('/', asslib.AssetLibraryPath)) + REPLACE(REPLACE(REPLACE(CASE ISNULL(ass.AssetLongName, '') WHEN '' THEN ass.AssetName ELSE ass.AssetLongName END + LOWER(RIGHT(ass.AssetFilename, 4)),'/','_'), ',', '_'),' ','_') AS AssetFilename
	,	'Product' AS AssetLevel
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
			AND asslib.AssetPushConfiguration = 'Product Images (IPEX Std)'
	WHERE prc.CompanyCode = @CompanyCode
	AND	prdass.AssetID IS NOT NULL
	AND ISNULL(prd.[SupersededByProductCode], '') = ''
	AND	prd.ProductStatus in ('New','Regular','No Longer Replenished')
	AND	ISNULL(prc.IsOEMBrand, 'No') = 'No'
	AND	ISNULL(prd.ProductIsOEM, 'No') = 'No'
	AND	(ISNULL(prc.LastSoldDate,GETDATE()) > DATEADD(YEAR, -3, GetDate()) AND prc.CurrentListPrice IS NOT NULL AND prc.TradeListName IS NOT NULL)
	
	UNION
				
	SELECT prd.ProductCode
	,	'EN' AS [Language]
	,	prdass.AssetType
	,	'' AS IsFamilyImage
	,	asslib.AssetLibraryPath
	,	LEFT(asslib.AssetLibraryPath, CHARINDEX('/', asslib.AssetLibraryPath)) + REPLACE(REPLACE(REPLACE(CASE ISNULL(ass.AssetLongName, '') WHEN '' THEN ass.AssetName ELSE ass.AssetLongName END + LOWER(RIGHT(ass.AssetFilename, 4)),'/','_'), ',', '_'),' ','_') AS AssetFilename
	,	'Material' AS AssetLevel
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
	AND prc.CompanyCode = @CompanyCode
	AND	prdass.AssetID IS NOT NULL
	AND ISNULL(prd.[SupersededByProductCode], '') = ''
	AND	prd.ProductStatus in ('New','Regular','No Longer Replenished')
	AND	ISNULL(prc.IsOEMBrand, 'No') = 'No'
	AND	ISNULL(prd.ProductIsOEM, 'No') = 'No'
	AND	(ISNULL(prc.LastSoldDate,GETDATE()) > DATEADD(YEAR, -3, GetDate()) AND prc.CurrentListPrice IS NOT NULL AND prc.TradeListName IS NOT NULL)
	
	UNION
			
	SELECT prd.ProductCode
	,	'FR' AS [Language]
	,	prdass.AssetType
	,	'' AS IsFamilyImage
	,	asslib.AssetLibraryPath
	,	LEFT(asslib.AssetLibraryPath, CHARINDEX('/', asslib.AssetLibraryPath)) + REPLACE(REPLACE(REPLACE(CASE isnull(ass.AssetLongName, '') WHEN '' THEN ass.AssetName ELSE ass.AssetLongName END + LOWER(RIGHT(ass.AssetFilename, 4)),'/','_'), ',', '_'),' ','_') AS AssetFilename
	,	'Material' AS AssetLevel
	FROM dbo.ProductCompanyView AS prc 
		LEFT JOIN dbo.ProductView AS prd 
			ON prd.ProductID = prc.ProductID 
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
	AND prc.CompanyCode = @CompanyCode
	AND	prdass.AssetID IS NOT NULL
	AND ISNULL(prd.[SupersededByProductCode], '') = ''
	AND	prd.ProductStatus in ('New','Regular','No Longer Replenished')
	AND	ISNULL(prc.IsOEMBrand, 'No') = 'No'
	AND	ISNULL(prd.ProductIsOEM, 'No') = 'No'
	AND	(ISNULL(prc.LastSoldDate,GETDATE()) > DATEADD(YEAR, -3, GetDate()) AND prc.CurrentListPrice IS NOT NULL AND prc.TradeListName IS NOT NULL)
	
	UNION
				
	SELECT prd.ProductCode
	,	'' AS [Language]
	,	'2D Drawing' AS AssetType
	,	'' AS IsFamilyImage
	,	asslib.AssetLibraryPath
	,	LEFT(asslib.AssetLibraryPath, CHARINDEX('/', asslib.AssetLibraryPath)) + REPLACE(REPLACE(REPLACE(CASE isnull(ass.AssetLongName, '') WHEN '' THEN ass.AssetName ELSE ass.AssetLongName END + LOWER(RIGHT(ass.AssetFilename, 4)),'/','_'), ',', '_'),' ','_') AS AssetFilename
	,	'Product-Source' AS AssetLevel
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
	WHERE prc.CompanyCode = @CompanyCode
	AND	prsass.AssetID IS NOT NULL
	AND ISNULL(prd.[SupersededByProductCode], '') = ''
	AND	prd.ProductStatus in ('New','Regular','No Longer Replenished')
	AND	ISNULL(prc.IsOEMBrand, 'No') = 'No'
	AND	ISNULL(prd.ProductIsOEM, 'No') = 'No'
	AND	(ISNULL(prc.LastSoldDate,GETDATE()) > DATEADD(YEAR, -3, GetDate()) AND prc.CurrentListPrice IS NOT NULL AND prc.TradeListName IS NOT NULL)

	) Z ORDER BY Z.ProductCode
		

END
























