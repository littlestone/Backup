USE [DataWarehouse_PIM]
GO
/****** Object:  StoredProcedure [dbo].[spd_RPT_MasterProductData]    Script Date: 2016-05-02 3:34:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




























-- =============================================
-- Author:		Vianney Rebetez, Junjie Tang
-- Create date: 2016-04-27
-- Description:	PIM Master Product Data Report (Product Info)
-- =============================================
ALTER PROCEDURE [dbo].[spd_RPT_MasterProductData]
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
	SELECT DISTINCT prd.[ProductCode]
	,	prd.[AltProductCode]
	,   prd.[UniPartNumber]
	,	prd.OEMNumber
	,	prd.[UPCCode]
	,	prd.AlternateUPCCode
	,	prd.[ProductCategory]
	,	prd.[ProductSubCategory]
	,	prc.Brand
	,	prc.IsOEMBrand
	,	iih.ProductLine ProductLine
	,	iih.ProductGroup ProductGroup
	,	iih.SuperGroup SuperGroup
	,	iih.ProductType ProductType
	,	iih.MarketSegment MarketSegment
	,	prd.[AttributeBasedDescI] ProductDescriptionEnglishImperial
	,	prdf.[AttributeBasedDescI] ProductDescriptionFrenchImperial
	,	prd.[AttributeBasedDescM] ProductDescriptionEnglishMetric
	,	prdf.[AttributeBasedDescM] ProductDescriptionFrenchMetric
	,	prd.FeaturesAndBenefits
	,	prd.[BaseUOM]
	,	prd.[BaseQty]
	,	prd.[ShippingWeight]
	,	prd.[InfofloItemType] [InventoryType]
	,   prd.[ProductIsOEM]
	,	prd.[ProductStatus]
	,	prd.[CreationDate]
	,	prd.[ObsolescenceDate]
	,   prd.SupersededByProductCode
	,	prd.[ABCCategory]
	,	prd.[DuplicateReasonCode]
	,	prd.[NonRetNonCanc]
	,	prd.[PrimarySourceType]
	,	prd.[PurchasedFromAliaxis]
	,	prd.[Class]
	,	prd.[ProductType] TypeOf
	,	prd.[Diameter1I] Diameter1Imperial
	,	prd.[Diameter1M] Diameter1Metric
	,	prd.[Diameter2I] Diameter2Imperial
	,	prd.[Diameter2M] Diameter2Metric
	,	prd.[Diameter3I] Diameter3Imperial
	,	prd.[Diameter3M] Diameter3Metric
	,	prd.[Diameter4I] Diameter4Imperial
	,	prd.[Diameter4M] Diameter4Metric
	,	prd.[SizeI] SizeImperial
	,	prd.[SizeM] SizeMetric
	,	prd.[LengthI] LengthImperial
	,	prd.[LengthM] LengthMetric
	,	prd.[Angle]
	,	prd.[Connection] ConnectionType
	,	prd.[Certification]
	,	prd.[Material]
	,	prd.[GlobeMaterial]
	,	prd.[SealMaterial]
	,	prd.[Color]
	,	prd.[GlobeColor]
	,	prd.[Application]
	,	prd.[Component]
	,	prd.[DimensionalStandard]
	,	prd.[FeatureA]
	,	prd.[FeatureB]
	,	prd.[Function]
	,	prd.[LampIncluded]
	,	prd.[LampType]
	,	prd.[MountType]
	,	prd.[NumberOfGangs]
	,	prd.[NumberOfLamps]
	,	prd.[NumberOfOutlets]
	,	prd.[Options]
	,	prd.[RadiusI]
	,	prd.[RadiusM]
	,	prd.[Series]
	,	prd.[Shape]
	,	prd.[ThicknessI]
	,	prd.[ThicknessM]
	,	prd.[Torque]
	,	prd.[Voltage]
	,	prd.[Watt]
	,	prd.[FlameSpread]
	,	prd.[SmokeDevelopment]
	,	prd.[UNSPSC]
	,	prd.[IGCC]
	,	prd.[ETIM]
	,	tcv.TariffCodeCode
	,	tcv.TariffCodeLongDescription
	,	tcv.TariffCodeCA
	,	tcv.TariffCodeUS
	,	dgcv.DGCodeCode
	,	dgcv.[Description] [DGCodeDescription] 
	,	dgcv.[Message] DGCodeMessage
	,	dgcv.UNCodes DangerousGoodsUNCodes
	,	dgcv.UNCodeWeights DangerousGoodsUNPct
	,	prd.[DGFlashpointC] DangerousGoodsFlashpointC
	,	prd.[DGFlashpointF] DangerousGoodsFlashpointF
	,	prd.[CountryOfOriginCode] CountryOfOrigin
	,	psc.CertifiedStandards
	,	prd.[CertificationExternalNotes]
	,	prc.LastSoldDate
	,	prc.TradeListName
	,	prc.TradeListDescription
	,	prc.CurrentListPrice
	,	prc.CurrentListPriceEffectiveDate
	,	prc.FutureListPrice
	,	prc.FutureListPriceEffectiveDate
	,	prc.Currency
	,	prc.PricePer
	,	mh.ProductLine MarketingProductLine
	,	mh.[Application] ProductLineApplication
	,	mh.MarketSegment ProductLineSegment
	,	mh.[Description] ProductLineDescriptionEnglish
	,	mhf.[Description] ProductLineDescriptionFrench
	,	mh.FeaturesAndBenefits ProductLineFeaturesAndBenefitsEnglish
	,	mhf.FeaturesAndBenefits ProductLineFeaturesAndBenefitsFrench
	,	mh.WebsiteURL
	FROM ProductCompanyView prc 
		LEFT JOIN ProductView prd 
			ON prd.ProductID = prc.ProductID 
		LEFT JOIN ProductViewFrench prdf 
			ON prdf.ProductID = prc.ProductID 
		LEFT JOIN TariffCodeView tcv 
			ON tcv.TariffCodeID = prd.TariffCodeID 
		LEFT JOIN DangerousGoodsCodeView dgcv 
			ON dgcv.DGCodeID = prd.DangerousGoodCodeID 
		LEFT JOIN InfofloHierarchyView iih 
			ON iih.ProductLineID = prd.ProductLineID 
		LEFT JOIN MarketingHierarchyView mh 
			ON mh.ProductLineID = prc.ProductLineID 
		LEFT JOIN MarketingHierarchyViewFrench mhf 
			ON mhf.ProductLineID = prc.ProductLineID 
		LEFT JOIN (SELECT prs.ProductID
				   ,	STUFF((SELECT DISTINCT ';' + [Standard]
				   			   FROM ProductSourceCertificationView x 
				   			       INNER JOIN ProductSourceView y 
				   				       ON x.ProductSourceID = y.ProductSourceID
				   			   WHERE x.CertificationLinkType = 'CertifiedStandard' 
				   			   AND y.ProductID = prs.ProductID FOR xml path('')), 1, 1, '') CertifiedStandards
				   FROM ProductSourceCertificationView scv 
				       INNER JOIN ProductSourceView prs 
				   	       ON prs.ProductSourceID = scv.ProductSourceID
				   WHERE scv.CertificationLinkType = 'CertifiedStandard' 
				   AND prs.ProductID <> '0'
				   GROUP BY prs.ProductID) psc 
			ON psc.ProductID = prd.ProductID
	WHERE  prd.ProductID IS NOT NULL 
	AND prc.CompanyCode = @CompanyCode
	AND (@MarketSegment = 'ALL' OR RIGHT(iih.MarketSegment, LEN(iih.MarketSegment) - CHARINDEX(' - ', iih.MarketSegment) - 2) = @MarketSegment)
	AND (@ExcludeOEMProduct <> 'Yes' OR (ISNULL(prd.ProductIsOEM, 'No') = 'No' AND ISNULL(prc.IsOEMBrand, 'No') = 'No'))
	AND (@ExcludeSuperseededProduct <> 'Yes' OR ISNULL(prd.[SupersededByProductCode], '') = '') 
	AND (@ExcludeProductWithoutPrice <> 'Yes' OR (ISNULL(prc.TradeListName,'') <> '' AND ISNULL(prc.CurrentListPrice,'')<>''))
	AND (prd.ProductStatus IN ('New','Regular','No Longer Replenished')
		 OR (prd.ProductStatus = 'Obsolete' AND @IncludeProductObsoleteSince <> '0' AND (@IncludeProductObsoleteSince = 'ALL' or ISNULL(prd.ObsolescenceDate, GETDATE()) >= DATEADD(MONTH, -cast(@IncludeProductObsoleteSince AS int), GetDate()))))
	AND (@ExcludeProductNotSoldSince = '0' OR ISNULL(prc.LastSoldDate, GETDATE()) >= DATEADD(YEAR, -CAST(@ExcludeProductNotSoldSince AS int), GetDate()))
	AND (@IncludeNewProductCreatedSince = '0' OR ISNULL(prd.CreationDate, GETDATE()) >= DATEADD(MONTH, -CAST(@IncludeNewProductCreatedSince AS int), GetDate()))

END


















