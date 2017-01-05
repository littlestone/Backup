USE [DataWarehouse_PIM]
GO

/****** Object:  Table [dbo].[ProductCompany]    Script Date: 01/04/2016 5:46:41 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ProductCompany](
	[ProductCompanyID] [nvarchar](255) NULL,
	[ProductCompanyCode] [nvarchar](255) NULL,
	[CurrentListPrice] [nvarchar](255) NULL,
	[CurrentListPriceEffectiveDate] [nvarchar](255) NULL,
	[CreateTS] [smalldatetime] NULL,
	[UpdateTS] [smalldatetime] NULL
) ON [PRIMARY]

GO


