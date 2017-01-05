USE [DataWarehouse_PIM]
GO

/****** Object:  Table [dbo].[ProductCompanyAssetView]    Script Date: 01/04/2016 5:46:50 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ProductCompanyAssetView](
	[ProductCompanyID] [nvarchar](255) NULL,
	[AssetID] [nvarchar](255) NULL,
	[AssetType] [nvarchar](255) NULL,
	[AssetLevel] [nvarchar](255) NULL
) ON [PRIMARY]

GO


