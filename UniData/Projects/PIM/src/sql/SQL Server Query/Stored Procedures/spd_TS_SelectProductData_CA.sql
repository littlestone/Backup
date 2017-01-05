USE [DataWarehouse_PIM]
GO
/****** Object:  StoredProcedure [dbo].[spd_TS_SelectProductData_CA]    Script Date: 2016-05-02 3:35:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


































-- =============================================
-- Author:		Vianney Rebetez, Junjie Tang
-- Create date: 2016-03-11
-- Description:	PIM Customer Trade Service Report (Product Info)
-- =============================================
ALTER PROCEDURE [dbo].[spd_TS_SelectProductData_CA]
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
	SELECT DISTINCT prd.[ProductCode]
	,	prd.[AltProductCode]
	,   prd.[UniPartNumber]
	,	prd.[UPCCode]
	,	prd.[ProductCategory]
	,	prd.[ProductSubCategory]
	,	iih.ProductLine ProductLine
	,	iih.ProductGroup ProductGroup
	,	iih.SuperGroup SuperGroup
	,	iih.ProductType ProductType
	,	iih.MarketSegment MarketSegment
	,	prd.[AttributeBasedDescI] ProductDescriptionEnglishImperial
	,	prdf.[AttributeBasedDescI] ProductDescriptionFrenchImperial
	,	prd.[AttributeBasedDescM] ProductDescriptionEnglishMetric
	,	prdf.[AttributeBasedDescM] ProductDescriptionFrenchMetric
	,	prc.Brand
	,	prd.[ProductStatus]
	,	prd.[BaseUOM]
	,	prd.[BaseQty]
	,	prd.[ShippingWeight] UnitWeightKG
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
	,	tcv.TariffCodeCA
	,	tcv.TariffCodeUS
	,	dgcv.UNCodes DangerousGoodsUNCodes
	,	dgcv.UNCodeWeights DangerousGoodsUNPct
	,	prd.[DGFlashpointC] DangerousGoodsFlashpointC
	,	prd.[DGFlashpointF] DangerousGoodsFlashpointF
	,	prd.[CountryOfOriginCode] CountryOfOrigin
	,	prc.CurrentListPrice Price
	,	prc.PricePer
	,	case prc.Currency when 'US DOLLAR' then 'USD' when 'CANADIAN DOLLAR' then 'CAD' else '' end Currency
	,	prc.CurrentListPriceEffectiveDate PriceEffectiveDate
	,	prd.[NoCertification]
	,	psc.CertifiedStandards
	,	prd.[CertificationExternalNotes]
	,	isnull(fab.FeaturesAndBenefits,'') + case when fab.FeaturesAndBenefits is not null and prd.FeaturesAndBenefits is not null then ';' else '' end + isnull(prd.FeaturesAndBenefits,'') "Features&BenefitsEnglish"
	,	isnull(fabf.FeaturesAndBenefits,'') /*+ case when fabf.FeaturesAndBenefits is not null and prd.FeaturesAndBenefits is not null then ';' else '' end + isnull(prd.FeaturesAndBenefits,'')*/ "Features&BenefitsFrench"
	,	prd.[UNSPSC]
	,	prd.[IGCC]
	,	prd.[ETIM]
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
		LEFT JOIN (SELECT prc.ProductID
					,	STUFF((SELECT DISTINCT ';' + FeaturesAndBenefits
								FROM MarketingHierarchyView x 
				   					INNER JOIN ProductCompanyView y 
				   						ON x.ProductLineID = y.ProductLineID
								WHERE y.ProductID = prc.ProductID FOR xml path('')), 1, 1, '') FeaturesAndBenefits
					FROM ProductCompanyView prc
					GROUP BY prc.ProductID) fab
			ON fab.ProductID = prd.ProductID
		LEFT JOIN (SELECT prc.ProductID
					,	STUFF((SELECT DISTINCT ';' + FeaturesAndBenefits
								FROM MarketingHierarchyViewFrench x 
				   					INNER JOIN ProductCompanyView y 
				   						ON x.ProductLineID = y.ProductLineID
								WHERE y.ProductID = prc.ProductID FOR xml path('')), 1, 1, '') FeaturesAndBenefits
					FROM ProductCompanyView prc
					GROUP BY prc.ProductID) fabf
			ON fabf.ProductID = prd.ProductID
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
	AND ISNULL(prd.[SupersededByProductCode], '') = '' 
	AND prd.ProductStatus in ('New','Regular','No Longer Replenished')
	AND ISNULL(prc.IsOEMBrand, 'No') = 'No' 
	AND ISNULL(prd.ProductIsOEM, 'No') = 'No' 
	AND (ISNULL(prc.LastSoldDate,GETDATE()) > DATEADD(YEAR, - 3, GetDate()) AND prc.CurrentListPrice IS NOT NULL AND prc.TradeListName is not null)
	AND (LEFT(iih.MarketSegment, 1) <> '5' AND ISNULL(mh.MarketSegment,'') <> 'MUNICIPAL')
	ORDER BY prd.ProductCode
	

END


































