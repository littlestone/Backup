USE [DataWarehouse_PIM]
GO

/****** Object:  Table [dbo].[TariffCodeView]    Script Date: 01/04/2016 5:48:02 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[TariffCodeView](
	[TariffCodeID] [nvarchar](255) NULL,
	[TariffCode] [nvarchar](255) NULL,
	[TariffCodeCA] [nvarchar](255) NULL,
	[TariffCodeUS] [nvarchar](255) NULL,
	[TariffCodeCode] [nvarchar](255) NULL,
	[TariffCodeLongDescription] [nvarchar](255) NULL,
	[TariffCodeShortDescription] [nvarchar](255) NULL
) ON [PRIMARY]

GO


