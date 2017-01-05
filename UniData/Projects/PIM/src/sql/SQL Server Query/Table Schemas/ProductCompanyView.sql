USE [DataWarehouse_PIM]
GO

/****** Object:  Table [dbo].[ProductCompanyView]    Script Date: 01/04/2016 5:47:08 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ProductCompanyView](
	[ProductCompanyID] [nvarchar](255) NULL,
	[ProductID] [nvarchar](255) NULL,
	[ProductCode] [nvarchar](255) NULL,
	[CompanyCode] [nvarchar](255) NULL,
	[PricePer] [nvarchar](255) NULL,
	[Currency] [nvarchar](255) NULL,
	[CurrentListPrice] [nvarchar](255) NULL,
	[CurrentListPriceEffectiveDate] [nvarchar](255) NULL,
	[FutureListPrice] [nvarchar](255) NULL,
	[FutureListPriceEffectiveDate] [nvarchar](255) NULL,
	[TradeListName] [nvarchar](255) NULL,
	[TradeListDescription] [nvarchar](255) NULL,
	[LastSoldDate] [nvarchar](255) NULL,
	[Brand] [nvarchar](255) NULL,
	[SubBrand] [nvarchar](255) NULL,
	[IsOEMBrand] [nvarchar](255) NULL,
	[ProductLineID] [nvarchar](255) NULL
) ON [PRIMARY]

GO


