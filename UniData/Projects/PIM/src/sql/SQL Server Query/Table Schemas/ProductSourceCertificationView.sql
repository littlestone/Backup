USE [DataWarehouse_PIM]
GO

/****** Object:  Table [dbo].[ProductSourceCertificationView]    Script Date: 01/04/2016 5:47:26 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ProductSourceCertificationView](
	[ProductSourceID] [nvarchar](255) NULL,
	[CertificationLinkType] [nvarchar](255) NULL,
	[Standard] [nvarchar](255) NULL,
	[Agency] [nvarchar](255) NULL
) ON [PRIMARY]

GO


