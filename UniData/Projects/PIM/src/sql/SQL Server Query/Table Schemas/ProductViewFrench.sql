USE [DataWarehouse_PIM]
GO

/****** Object:  Table [dbo].[ProductViewFrench]    Script Date: 01/04/2016 5:47:53 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ProductViewFrench](
	[ProductID] [nvarchar](255) NULL,
	[AttributeBasedDescI] [nvarchar](255) NULL,
	[AttributeBasedDescM] [nvarchar](255) NULL,
	[ProductType] [nvarchar](255) NULL,
	[Material] [nvarchar](255) NULL,
	[Color] [nvarchar](255) NULL,
	[Class] [nvarchar](255) NULL,
	[Connection] [nvarchar](255) NULL,
	[Certification] [nvarchar](255) NULL,
	[Application] [nvarchar](255) NULL,
	[Component] [nvarchar](255) NULL,
	[DimensionalStandard] [nvarchar](255) NULL,
	[FeatureA] [nvarchar](255) NULL,
	[FeatureB] [nvarchar](255) NULL,
	[Function] [nvarchar](255) NULL,
	[GlobeColor] [nvarchar](255) NULL,
	[GlobeMaterial] [nvarchar](255) NULL,
	[MountType] [nvarchar](255) NULL,
	[Options] [nvarchar](255) NULL,
	[SealMaterial] [nvarchar](255) NULL,
	[Series] [nvarchar](255) NULL,
	[Shape] [nvarchar](255) NULL,
	[Torque] [nvarchar](255) NULL,
	[Voltage] [nvarchar](255) NULL
) ON [PRIMARY]

GO


