USE [DataWarehouse_PIM]
GO

/****** Object:  Table [dbo].[MarketingHierarchyView]    Script Date: 01/04/2016 5:45:44 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[MarketingHierarchyView](
	[ProductLineID] [nvarchar](255) NULL,
	[ProductLine] [nvarchar](255) NULL,
	[Application] [nvarchar](255) NULL,
	[MarketSegment] [nvarchar](255) NULL,
	[Company] [nvarchar](255) NULL,
	[Description] [nvarchar](max) NULL,
	[FeaturesAndBenefits] [nvarchar](max) NULL,
	[WebsiteURL] [nvarchar](255) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO


