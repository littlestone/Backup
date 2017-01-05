USE [DataWarehouse_PIM]
GO
/****** Object:  StoredProcedure [dbo].[spd_RPT_MasterProductAssetsData]    Script Date: 2016-05-02 5:17:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


























-- =============================================
-- Author:		Vianney Rebetez, Junjie Tang
-- Create date: 2016-04-27
-- Description:	PIM Master Product Data Report (Assets Info)
-- =============================================
ALTER PROCEDURE [dbo].[spd_RPT_MasterProductAssetsData]
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
	IF @CompanyCode NOT IN ('01', '02', '03', '16')
	BEGIN
		RAISERROR('Invalid parameter { %s }: acceptable value are 01, 02, 03 and 16.', 16, 1, @CompanyCode)
		RETURN -1
	END
	IF @ExcludeProductNotSoldSince = 'N/A' SET @ExcludeProductNotSoldSince = 0
	IF @IncludeNewProductCreatedSince = 'N/A' SET @IncludeNewProductCreatedSince = 0
	IF @IncludeProductObsoleteSince = 'N/A' SET @IncludeProductObsoleteSince = 0

    -- Insert statements for procedure here
	SELECT Z.* FROM (

	SELECT prd.ProductCode
	,	'EN' AS [Language]
	,	prcass.AssetType
	,	'' AS IsFamilyImage
	,   ass.AssetName
	,	ass.AssetLongName
	,	CASE prcass.AssetLevel WHEN 'Product' THEN 'Product-Company' ELSE prcass.AssetLevel END AS AssetLevel
	,	asslib.AssetLibraryPath
	FROM dbo.ProductCompanyView AS prc 
		LEFT JOIN dbo.ProductView AS prd 
			ON prd.ProductID = prc.ProductID 
		LEFT JOIN InfofloHierarchyView iih 
			ON iih.ProductLineID = prd.ProductLineID
		LEFT JOIN dbo.ProductCompanyAssetView AS prcass 
			ON prcass.ProductCompanyID = prc.ProductCompanyID 
		LEFT JOIN dbo.AssetView AS ass 
			ON ass.AssetID = prcass.AssetID 
		LEFT JOIN dbo.AssetLibraryView AS asslib 
			ON asslib.AssetID = ass.AssetID AND asslib.AssetPushQueue = 'Main Asset Push Queue'
	WHERE prcass.AssetID IS NOT NULL 
	AND prc.CompanyCode = @CompanyCode
	AND (@MarketSegment = 'ALL' OR RIGHT(iih.MarketSegment, LEN(iih.MarketSegment) - CHARINDEX(' - ', iih.MarketSegment) - 2) = @MarketSegment)
	AND (@ExcludeOEMProduct <> 'Yes' OR (ISNULL(prd.ProductIsOEM, 'No') = 'No' AND ISNULL(prc.IsOEMBrand, 'No') = 'No'))
	AND (@ExcludeSuperseededProduct <> 'Yes' OR ISNULL(prd.[SupersededByProductCode], '') = '') 
	AND (@ExcludeProductWithoutPrice <> 'Yes' OR (ISNULL(prc.TradeListName,'') <> '' AND ISNULL(prc.CurrentListPrice,'')<>''))
	AND (prd.ProductStatus IN ('New','Regular','No Longer Replenished')
		 OR (prd.ProductStatus = 'Obsolete' AND @IncludeProductObsoleteSince <> '0' AND (@IncludeProductObsoleteSince = 'ALL' or ISNULL(prd.ObsolescenceDate, GETDATE()) >= DATEADD(MONTH, -cast(@IncludeProductObsoleteSince AS int), GetDate()))))
	AND (@ExcludeProductNotSoldSince = '0' OR ISNULL(prc.LastSoldDate, GETDATE()) >= DATEADD(YEAR, -CAST(@ExcludeProductNotSoldSince AS int), GetDate()))
	AND (@IncludeNewProductCreatedSince = '0' OR ISNULL(prd.CreationDate, GETDATE()) >= DATEADD(MONTH, -CAST(@IncludeNewProductCreatedSince AS int), GetDate()))
	
	UNION
	
	SELECT prd.ProductCode
	,	'FR' AS [Language]
	,	prcass.AssetType
	,	'' AS IsFamilyImage
	,   ass.AssetName
	,	ass.AssetLongName
	,	CASE prcass.AssetLevel WHEN 'Product' THEN 'Product-Company' ELSE prcass.AssetLevel END AS AssetLevel
	,	asslib.AssetLibraryPath
	FROM dbo.ProductCompanyView AS prc
	    LEFT JOIN MarketingHierarchyView mh 
			ON mh.ProductLineID = prc.ProductLineID
		LEFT JOIN dbo.ProductView AS prd 
			ON prd.ProductID = prc.ProductID
		LEFT JOIN dbo.ProductCompanyAssetViewFrench AS prcass 
			ON prcass.ProductCompanyID = prc.ProductCompanyID 
		LEFT JOIN dbo.AssetView AS ass 
			ON ass.AssetID = prcass.AssetID 
		LEFT JOIN dbo.AssetLibraryView AS asslib 
			ON asslib.AssetID = ass.AssetID 
			AND asslib.AssetPushQueue = 'Main Asset Push Queue'
	WHERE prcass.AssetID IS NOT NULL
	AND prc.CompanyCode = @CompanyCode
	AND (@MarketSegment = 'ALL' OR RIGHT(mh.MarketSegment, LEN(mh.MarketSegment) - CHARINDEX(' - ', mh.MarketSegment) - 2) = @MarketSegment)
	AND (@ExcludeOEMProduct <> 'Yes' OR (ISNULL(prd.ProductIsOEM, 'No') = 'No' AND ISNULL(prc.IsOEMBrand, 'No') = 'No'))
	AND (@ExcludeSuperseededProduct <> 'Yes' OR ISNULL(prd.[SupersededByProductCode], '') = '') 
	AND (@ExcludeProductWithoutPrice <> 'Yes' OR (ISNULL(prc.TradeListName,'') <> '' AND ISNULL(prc.CurrentListPrice,'')<>''))
	AND (prd.ProductStatus IN ('New','Regular','No Longer Replenished')
		 OR (prd.ProductStatus = 'Obsolete' AND @IncludeProductObsoleteSince <> '0' AND (@IncludeProductObsoleteSince = 'ALL' or ISNULL(prd.ObsolescenceDate, GETDATE()) >= DATEADD(MONTH, -cast(@IncludeProductObsoleteSince AS int), GetDate()))))
	AND (@ExcludeProductNotSoldSince = '0' OR ISNULL(prc.LastSoldDate, GETDATE()) >= DATEADD(YEAR, -CAST(@ExcludeProductNotSoldSince AS int), GetDate()))
	AND (@IncludeNewProductCreatedSince = '0' OR ISNULL(prd.CreationDate, GETDATE()) >= DATEADD(MONTH, -CAST(@IncludeNewProductCreatedSince AS int), GetDate()))
				
	UNION
	
	SELECT prd.ProductCode
	,	'EN' AS [Language]
	,	'MSDS' AS AssetType
	,	'' AS IsFamilyImage
	,   ass.AssetName
	,	ass.AssetLongName
	,	'Product' AS AssetLevel
	,	asslib.AssetLibraryPath
	FROM dbo.ProductCompanyView AS prc
		LEFT JOIN MarketingHierarchyView mh 
			ON mh.ProductLineID = prc.ProductLineID
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
	WHERE prdass.AssetID IS NOT NULL 
	AND prc.CompanyCode = @CompanyCode
	AND (@MarketSegment = 'ALL' OR RIGHT(mh.MarketSegment, LEN(mh.MarketSegment) - CHARINDEX(' - ', mh.MarketSegment) - 2) = @MarketSegment)
	AND (@ExcludeOEMProduct <> 'Yes' OR (ISNULL(prd.ProductIsOEM, 'No') = 'No' AND ISNULL(prc.IsOEMBrand, 'No') = 'No'))
	AND (@ExcludeSuperseededProduct <> 'Yes' OR ISNULL(prd.[SupersededByProductCode], '') = '') 
	AND (@ExcludeProductWithoutPrice <> 'Yes' OR (ISNULL(prc.TradeListName,'') <> '' AND ISNULL(prc.CurrentListPrice,'')<>''))
	AND (prd.ProductStatus IN ('New','Regular','No Longer Replenished')
		 OR (prd.ProductStatus = 'Obsolete' AND @IncludeProductObsoleteSince <> '0' AND (@IncludeProductObsoleteSince = 'ALL' or ISNULL(prd.ObsolescenceDate, GETDATE()) >= DATEADD(MONTH, -cast(@IncludeProductObsoleteSince AS int), GetDate()))))
	AND (@ExcludeProductNotSoldSince = '0' OR ISNULL(prc.LastSoldDate, GETDATE()) >= DATEADD(YEAR, -CAST(@ExcludeProductNotSoldSince AS int), GetDate()))
	AND (@IncludeNewProductCreatedSince = '0' OR ISNULL(prd.CreationDate, GETDATE()) >= DATEADD(MONTH, -CAST(@IncludeNewProductCreatedSince AS int), GetDate()))
	
	UNION
				
	SELECT prd.ProductCode
	,	'FR' AS [Language]
	,	'MSDS' AS AssetType
	,	'' AS IsFamilyImage
	,   ass.AssetName
	,	ass.AssetLongName
	,	'Product' AS AssetLevel
	,	asslib.AssetLibraryPath
	FROM dbo.ProductCompanyView AS prc
		LEFT JOIN MarketingHierarchyView mh 
			ON mh.ProductLineID = prc.ProductLineID 
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
	WHERE prdass.AssetID IS NOT NULL
	AND prc.CompanyCode = @CompanyCode
	AND (@MarketSegment = 'ALL' OR RIGHT(mh.MarketSegment, LEN(mh.MarketSegment) - CHARINDEX(' - ', mh.MarketSegment) - 2) = @MarketSegment)
	AND (@ExcludeOEMProduct <> 'Yes' OR (ISNULL(prd.ProductIsOEM, 'No') = 'No' AND ISNULL(prc.IsOEMBrand, 'No') = 'No'))
	AND (@ExcludeSuperseededProduct <> 'Yes' OR ISNULL(prd.[SupersededByProductCode], '') = '') 
	AND (@ExcludeProductWithoutPrice <> 'Yes' OR (ISNULL(prc.TradeListName,'') <> '' AND ISNULL(prc.CurrentListPrice,'')<>''))
	AND (prd.ProductStatus IN ('New','Regular','No Longer Replenished')
		 OR (prd.ProductStatus = 'Obsolete' AND @IncludeProductObsoleteSince <> '0' AND (@IncludeProductObsoleteSince = 'ALL' or ISNULL(prd.ObsolescenceDate, GETDATE()) >= DATEADD(MONTH, -cast(@IncludeProductObsoleteSince AS int), GetDate()))))
	AND (@ExcludeProductNotSoldSince = '0' OR ISNULL(prc.LastSoldDate, GETDATE()) >= DATEADD(YEAR, -CAST(@ExcludeProductNotSoldSince AS int), GetDate()))
	AND (@IncludeNewProductCreatedSince = '0' OR ISNULL(prd.CreationDate, GETDATE()) >= DATEADD(MONTH, -CAST(@IncludeNewProductCreatedSince AS int), GetDate()))
	
	UNION
				
	SELECT prd.ProductCode
	,	'' AS [Language]
	,	'ProductImage' AS AssetType
	,	prdass.IsFamilyImage
	,   ass.AssetName
	,	ass.AssetLongName
	,	'Product' AS AssetLevel
	,	asslib.AssetLibraryPath
	FROM dbo.ProductCompanyView AS prc
		LEFT JOIN MarketingHierarchyView mh 
			ON mh.ProductLineID = prc.ProductLineID
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
	WHERE prdass.AssetID IS NOT NULL 
	AND prc.CompanyCode = @CompanyCode
	AND (@MarketSegment = 'ALL' OR RIGHT(mh.MarketSegment, LEN(mh.MarketSegment) - CHARINDEX(' - ', mh.MarketSegment) - 2) = @MarketSegment)
	AND (@ExcludeOEMProduct <> 'Yes' OR (ISNULL(prd.ProductIsOEM, 'No') = 'No' AND ISNULL(prc.IsOEMBrand, 'No') = 'No'))
	AND (@ExcludeSuperseededProduct <> 'Yes' OR ISNULL(prd.[SupersededByProductCode], '') = '') 
	AND (@ExcludeProductWithoutPrice <> 'Yes' OR (ISNULL(prc.TradeListName,'') <> '' AND ISNULL(prc.CurrentListPrice,'')<>''))
	AND (prd.ProductStatus IN ('New','Regular','No Longer Replenished')
		 OR (prd.ProductStatus = 'Obsolete' AND @IncludeProductObsoleteSince <> '0' AND (@IncludeProductObsoleteSince = 'ALL' or ISNULL(prd.ObsolescenceDate, GETDATE()) >= DATEADD(MONTH, -cast(@IncludeProductObsoleteSince AS int), GetDate()))))
	AND (@ExcludeProductNotSoldSince = '0' OR ISNULL(prc.LastSoldDate, GETDATE()) >= DATEADD(YEAR, -CAST(@ExcludeProductNotSoldSince AS int), GetDate()))
	AND (@IncludeNewProductCreatedSince = '0' OR ISNULL(prd.CreationDate, GETDATE()) >= DATEADD(MONTH, -CAST(@IncludeNewProductCreatedSince AS int), GetDate()))
	
	UNION
				
	SELECT prd.ProductCode
	,	'EN' AS [Language]
	,	prdass.AssetType
	,	'' AS IsFamilyImage
	,   ass.AssetName
	,	ass.AssetLongName
	,	'Material' AS AssetLevel
	,	asslib.AssetLibraryPath
	FROM dbo.ProductCompanyView AS prc
		LEFT JOIN MarketingHierarchyView mh 
			ON mh.ProductLineID = prc.ProductLineID
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
	WHERE X.ID IS NULL
	AND	prdass.AssetID IS NOT NULL
	AND prc.CompanyCode = @CompanyCode
	AND (@MarketSegment = 'ALL' OR RIGHT(mh.MarketSegment, LEN(mh.MarketSegment) - CHARINDEX(' - ', mh.MarketSegment) - 2) = @MarketSegment)
	AND (@ExcludeOEMProduct <> 'Yes' OR (ISNULL(prd.ProductIsOEM, 'No') = 'No' AND ISNULL(prc.IsOEMBrand, 'No') = 'No'))
	AND (@ExcludeSuperseededProduct <> 'Yes' OR ISNULL(prd.[SupersededByProductCode], '') = '') 
	AND (@ExcludeProductWithoutPrice <> 'Yes' OR (ISNULL(prc.TradeListName,'') <> '' AND ISNULL(prc.CurrentListPrice,'')<>''))
	AND (prd.ProductStatus IN ('New','Regular','No Longer Replenished')
		 OR (prd.ProductStatus = 'Obsolete' AND @IncludeProductObsoleteSince <> '0' AND (@IncludeProductObsoleteSince = 'ALL' or ISNULL(prd.ObsolescenceDate, GETDATE()) >= DATEADD(MONTH, -cast(@IncludeProductObsoleteSince AS int), GetDate()))))
	AND (@ExcludeProductNotSoldSince = '0' OR ISNULL(prc.LastSoldDate, GETDATE()) >= DATEADD(YEAR, -CAST(@ExcludeProductNotSoldSince AS int), GetDate()))
	AND (@IncludeNewProductCreatedSince = '0' OR ISNULL(prd.CreationDate, GETDATE()) >= DATEADD(MONTH, -CAST(@IncludeNewProductCreatedSince AS int), GetDate()))
	
	UNION
			
	SELECT prd.ProductCode
	,	'FR' AS [Language]
	,	prdass.AssetType
	,	'' AS IsFamilyImage
	,   ass.AssetName
	,	ass.AssetLongName
	,	'Material' AS AssetLevel
	,	asslib.AssetLibraryPath
	FROM dbo.ProductCompanyView AS prc
		LEFT JOIN MarketingHierarchyView mh 
			ON mh.ProductLineID = prc.ProductLineID
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
	WHERE Y.ID IS NULL
	AND	prdass.AssetID IS NOT NULL
	AND prc.CompanyCode = @CompanyCode
	AND (@MarketSegment = 'ALL' OR RIGHT(mh.MarketSegment, LEN(mh.MarketSegment) - CHARINDEX(' - ', mh.MarketSegment) - 2) = @MarketSegment)
	AND (@ExcludeOEMProduct <> 'Yes' OR (ISNULL(prd.ProductIsOEM, 'No') = 'No' AND ISNULL(prc.IsOEMBrand, 'No') = 'No'))
	AND (@ExcludeSuperseededProduct <> 'Yes' OR ISNULL(prd.[SupersededByProductCode], '') = '') 
	AND (@ExcludeProductWithoutPrice <> 'Yes' OR (ISNULL(prc.TradeListName,'') <> '' AND ISNULL(prc.CurrentListPrice,'')<>''))
	AND (prd.ProductStatus IN ('New','Regular','No Longer Replenished')
		 OR (prd.ProductStatus = 'Obsolete' AND @IncludeProductObsoleteSince <> '0' AND (@IncludeProductObsoleteSince = 'ALL' or ISNULL(prd.ObsolescenceDate, GETDATE()) >= DATEADD(MONTH, -cast(@IncludeProductObsoleteSince AS int), GetDate()))))
	AND (@ExcludeProductNotSoldSince = '0' OR ISNULL(prc.LastSoldDate, GETDATE()) >= DATEADD(YEAR, -CAST(@ExcludeProductNotSoldSince AS int), GetDate()))
	AND (@IncludeNewProductCreatedSince = '0' OR ISNULL(prd.CreationDate, GETDATE()) >= DATEADD(MONTH, -CAST(@IncludeNewProductCreatedSince AS int), GetDate()))
	
	UNION
				
	SELECT prd.ProductCode
	,	'' AS [Language]
	,	'2D Drawing' AS AssetType
	,	'' AS IsFamilyImage
	,   ass.AssetName
	,	ass.AssetLongName
	,	'Product-Source' AS AssetLevel
	,	asslib.AssetLibraryPath
	FROM dbo.ProductCompanyView AS prc
		LEFT JOIN MarketingHierarchyView mh 
			ON mh.ProductLineID = prc.ProductLineID
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
	WHERE prsass.AssetID IS NOT NULL 
	AND prc.CompanyCode = @CompanyCode
	AND (@MarketSegment = 'ALL' OR RIGHT(mh.MarketSegment, LEN(mh.MarketSegment) - CHARINDEX(' - ', mh.MarketSegment) - 2) = @MarketSegment)
	AND (@ExcludeOEMProduct <> 'Yes' OR (ISNULL(prd.ProductIsOEM, 'No') = 'No' AND ISNULL(prc.IsOEMBrand, 'No') = 'No'))
	AND (@ExcludeSuperseededProduct <> 'Yes' OR ISNULL(prd.[SupersededByProductCode], '') = '') 
	AND (@ExcludeProductWithoutPrice <> 'Yes' OR (ISNULL(prc.TradeListName,'') <> '' AND ISNULL(prc.CurrentListPrice,'')<>''))
	AND (prd.ProductStatus IN ('New','Regular','No Longer Replenished')
		 OR (prd.ProductStatus = 'Obsolete' AND @IncludeProductObsoleteSince <> '0' AND (@IncludeProductObsoleteSince = 'ALL' or ISNULL(prd.ObsolescenceDate, GETDATE()) >= DATEADD(MONTH, -cast(@IncludeProductObsoleteSince AS int), GetDate()))))
	AND (@ExcludeProductNotSoldSince = '0' OR ISNULL(prc.LastSoldDate, GETDATE()) >= DATEADD(YEAR, -CAST(@ExcludeProductNotSoldSince AS int), GetDate()))
	AND (@IncludeNewProductCreatedSince = '0' OR ISNULL(prd.CreationDate, GETDATE()) >= DATEADD(MONTH, -CAST(@IncludeNewProductCreatedSince AS int), GetDate()))

	) Z ORDER BY Z.ProductCode
		

END


























