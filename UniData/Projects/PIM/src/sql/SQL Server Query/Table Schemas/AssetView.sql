USE [DataWarehouse_PIM]
GO

/****** Object:  Table [dbo].[AssetView]    Script Date: 01/04/2016 5:44:24 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[AssetView](
	[AssetID] [nvarchar](255) NULL,
	[AssetName] [nvarchar](255) NULL,
	[AssetLongName] [nvarchar](255) NULL,
	[AssetFilename] [nvarchar](255) NULL,
	[AssetFileFormat] [nvarchar](255) NULL,
	[AssetMimeType] [nvarchar](255) NULL,
	[AssetSize] [nvarchar](255) NULL,
	[ImageHeight] [nvarchar](255) NULL,
	[ImageWidth] [nvarchar](255) NULL
) ON [PRIMARY]

GO


