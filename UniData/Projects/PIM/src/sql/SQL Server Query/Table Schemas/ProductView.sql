USE [DataWarehouse_PIM]
GO

/****** Object:  Table [dbo].[ProductView]    Script Date: 01/04/2016 5:47:44 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ProductView](
	[ProductID] [nvarchar](255) NULL,
	[InfofloCPN] [nvarchar](255) NULL,
	[ProductCode] [nvarchar](255) NULL,
	[AltProductCode] [nvarchar](255) NULL,
	[UPCCode] [nvarchar](255) NULL,
	[AlternateUPCCode] [nvarchar](255) NULL,
	[UniPartNumber] [nvarchar](255) NULL,
	[OEMNumber] [nvarchar](255) NULL,
	[ProductCategory] [nvarchar](255) NULL,
	[ProductSubCategory] [nvarchar](255) NULL,
	[AttributeBasedDescI] [nvarchar](255) NULL,
	[AttributeBasedDescM] [nvarchar](255) NULL,
	[FeaturesAndBenefits] [nvarchar](max) NULL,
	[InfofloItemType] [nvarchar](255) NULL,
	[ProductIsOEM] [nvarchar](255) NULL,
	[ProductStatus] [nvarchar](255) NULL,
	[CreationDate] [nvarchar](255) NULL,
	[ObsolescenceDate] [nvarchar](255) NULL,
	[ABCCategory] [nvarchar](255) NULL,
	[DuplicateReasonCode] [nvarchar](255) NULL,
	[NonRetNonCanc] [nvarchar](255) NULL,
	[PrimarySourceType] [nvarchar](255) NULL,
	[PurchasedFromAliaxis] [nvarchar](255) NULL,
	[DGFlashpointC] [nvarchar](255) NULL,
	[DGFlashpointF] [nvarchar](255) NULL,
	[BaseUOM] [nvarchar](255) NULL,
	[BaseQty] [nvarchar](255) NULL,
	[ShippingWeight] [nvarchar](255) NULL,
	[Length] [nvarchar](255) NULL,
	[Width] [nvarchar](255) NULL,
	[Height] [nvarchar](255) NULL,
	[ProductType] [nvarchar](255) NULL,
	[Material] [nvarchar](255) NULL,
	[Color] [nvarchar](255) NULL,
	[Class] [nvarchar](255) NULL,
	[Connection] [nvarchar](255) NULL,
	[Certification] [nvarchar](255) NULL,
	[Application] [nvarchar](255) NULL,
	[Angle] [nvarchar](255) NULL,
	[Component] [nvarchar](255) NULL,
	[Diameter1I] [nvarchar](255) NULL,
	[Diameter1M] [nvarchar](255) NULL,
	[Diameter2I] [nvarchar](255) NULL,
	[Diameter2M] [nvarchar](255) NULL,
	[Diameter3I] [nvarchar](255) NULL,
	[Diameter3M] [nvarchar](255) NULL,
	[Diameter4I] [nvarchar](255) NULL,
	[Diameter4M] [nvarchar](255) NULL,
	[DimensionalStandard] [nvarchar](255) NULL,
	[FeatureA] [nvarchar](255) NULL,
	[FeatureB] [nvarchar](255) NULL,
	[Function] [nvarchar](255) NULL,
	[GlobeColor] [nvarchar](255) NULL,
	[GlobeMaterial] [nvarchar](255) NULL,
	[LampIncluded] [nvarchar](255) NULL,
	[LampType] [nvarchar](255) NULL,
	[LengthI] [nvarchar](255) NULL,
	[LengthM] [nvarchar](255) NULL,
	[MountType] [nvarchar](255) NULL,
	[NumberOfGangs] [nvarchar](255) NULL,
	[NumberOfLamps] [nvarchar](255) NULL,
	[NumberOfOutlets] [nvarchar](255) NULL,
	[SealMaterial] [nvarchar](255) NULL,
	[Series] [nvarchar](255) NULL,
	[Shape] [nvarchar](255) NULL,
	[SizeI] [nvarchar](255) NULL,
	[SizeM] [nvarchar](255) NULL,
	[ThicknessI] [nvarchar](255) NULL,
	[ThicknessM] [nvarchar](255) NULL,
	[Torque] [nvarchar](255) NULL,
	[Voltage] [nvarchar](255) NULL,
	[Watt] [nvarchar](255) NULL,
	[Options] [nvarchar](255) NULL,
	[RadiusI] [nvarchar](255) NULL,
	[RadiusM] [nvarchar](255) NULL,
	[FlameSpread] [nvarchar](255) NULL,
	[SmokeDevelopment] [nvarchar](255) NULL,
	[NoCertification] [nvarchar](255) NULL,
	[CertificationExternalNotes] [nvarchar](255) NULL,
	[ProductLineID] [nvarchar](255) NULL,
	[ETIM] [nvarchar](255) NULL,
	[UNSPSC] [nvarchar](255) NULL,
	[IGCC] [nvarchar](255) NULL,
	[AlternateUPCProductCode] [nvarchar](255) NULL,
	[SupersededByProductCode] [nvarchar](255) NULL,
	[CountryOfOriginCode] [nvarchar](255) NULL,
	[CountryOfOriginName] [nvarchar](255) NULL,
	[DangerousGoodCodeID] [nvarchar](255) NULL,
	[TariffCodeID] [nvarchar](255) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

