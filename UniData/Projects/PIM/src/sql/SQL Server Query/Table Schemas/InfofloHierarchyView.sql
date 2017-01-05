USE [DataWarehouse_PIM]
GO

/****** Object:  Table [dbo].[InfofloHierarchyView]    Script Date: 01/04/2016 5:45:04 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[InfofloHierarchyView](
	[ProductLineID] [nvarchar](255) NULL,
	[ProductLine] [nvarchar](255) NULL,
	[ProductGroup] [nvarchar](255) NULL,
	[SuperGroup] [nvarchar](255) NULL,
	[ProductType] [nvarchar](255) NULL,
	[MarketSegment] [nvarchar](255) NULL
) ON [PRIMARY]

GO


