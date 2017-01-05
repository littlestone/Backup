USE [DataWarehouse_PIM]
GO

/****** Object:  Table [dbo].[AssetLibraryView]    Script Date: 01/04/2016 5:44:11 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[AssetLibraryView](
	[AssetID] [nvarchar](255) NULL,
	[AssetPushQueue] [nvarchar](255) NULL,
	[AssetPushConfiguration] [nvarchar](255) NULL,
	[AssetLibraryPath] [nvarchar](255) NULL
) ON [PRIMARY]

GO


