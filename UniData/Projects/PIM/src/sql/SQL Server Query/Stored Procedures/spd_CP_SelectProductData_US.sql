USE [DataWarehouse_PIM]
GO
/****** Object:  StoredProcedure [dbo].[spd_CP_SelectProductData_US]    Script Date: 2016-05-02 3:33:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






















-- =============================================
-- Author:		Vianney Rebetez, Junjie Tang
-- Create date: 2016-03-11
-- Description:	PIM Customer Standard Products Report (Product Info)
-- =============================================
ALTER PROCEDURE [dbo].[spd_CP_SelectProductData_US]
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
	,	prd.[AttributeBasedDescI] ProductDescriptionImperial
	,	prd.[AttributeBasedDescM] ProductDescriptionMetric
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
	,	prd.[NoCertification]
	,	psc.CertifiedStandards
	,	prd.[CertificationExternalNotes]
	,	isnull(fab.FeaturesAndBenefits,'') + case when fab.FeaturesAndBenefits is not null and prd.FeaturesAndBenefits is not null then ';' else '' end + isnull(prd.FeaturesAndBenefits,'') "Features&Benefits"
	,	prd.[UNSPSC]
	,	prd.[IGCC]
	,	prd.[ETIM]
	FROM ProductCompanyView prc 
		LEFT JOIN ProductView prd 
			ON prd.ProductID = prc.ProductID 
		LEFT JOIN TariffCodeView tcv 
			ON tcv.TariffCodeID = prd.TariffCodeID 
		LEFT JOIN DangerousGoodsCodeView dgcv 
			ON dgcv.DGCodeID = prd.DangerousGoodCodeID 
		LEFT JOIN InfofloHierarchyView iih 
			ON iih.ProductLineID = prd.ProductLineID 
		LEFT JOIN (SELECT prc.ProductID
					,	STUFF((SELECT DISTINCT ';' + FeaturesAndBenefits
								FROM MarketingHierarchyView x 
				   					INNER JOIN ProductCompanyView y 
				   						ON x.ProductLineID = y.ProductLineID
								WHERE y.ProductID = prc.ProductID FOR xml path('')), 1, 1, '') FeaturesAndBenefits
					FROM ProductCompanyView prc
					GROUP BY prc.ProductID) fab
			ON fab.ProductID = prd.ProductID
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
	AND (ISNULL(prc.LastSoldDate,GETDATE()) > DATEADD(YEAR, -3, GetDate()) AND prc.CurrentListPrice IS NOT NULL AND prc.TradeListName IS NOT NULL)
	ORDER BY prd.ProductCode

END






















