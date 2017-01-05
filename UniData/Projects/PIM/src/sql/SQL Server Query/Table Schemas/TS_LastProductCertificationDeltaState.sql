USE [DataWarehouse_PIM]
GO

/****** Object:  Table [dbo].[TS_LastProductCertificationDeltaState]    Script Date: 01/04/2016 5:45:14 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[TS_LastProductCertificationDeltaState](
	[ProductID] [nvarchar](255) NULL,
	[CertifiedStandard] [nvarchar](255) NULL,
	[CreateTS] [smalldatetime] NULL,
	[UpdateTS] [smalldatetime] NULL
) ON [PRIMARY]

GO


