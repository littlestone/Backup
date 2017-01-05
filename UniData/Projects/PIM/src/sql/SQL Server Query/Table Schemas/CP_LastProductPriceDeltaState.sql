USE [DataWarehouse_PIM]
GO

/****** Object:  Table [dbo].[CP_LastProductPriceDeltaState]    Script Date: 01/04/2016 5:45:24 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CP_LastProductPriceDeltaState](
	[ProductCompanyID] [nvarchar](255) NULL,
	[CompanyCode] [nvarchar](255) NULL,
	[CurrentListPrice] [nvarchar](255) NULL,
	[CurrentListPriceEffectiveDate] [nvarchar](255) NULL,
	[CreateTS] [smalldatetime] NULL,
	[UpdateTS] [smalldatetime] NULL
) ON [PRIMARY]

GO

