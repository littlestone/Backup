USE [DataWarehouse_PIM]
GO

/****** Object:  Table [dbo].[ProductSourceAssetView]    Script Date: 01/04/2016 5:47:16 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ProductSourceAssetView](
	[ProductSourceID] [nvarchar](255) NULL,
	[AssetID] [nvarchar](255) NULL,
	[AssetType] [nvarchar](255) NULL,
	[CertificationFileStandards] [nvarchar](255) NULL,
	[CertificationFileAgency] [nvarchar](255) NULL
) ON [PRIMARY]

GO


