USE [DataWarehouse_PIM]
GO

/****** Object:  Table [dbo].[ProductSourceView]    Script Date: 01/04/2016 5:47:36 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ProductSourceView](
	[ProductSourceID] [nvarchar](255) NULL,
	[ProductID] [nvarchar](255) NULL,
	[ProductCode] [nvarchar](255) NULL,
	[SourceCode] [nvarchar](255) NULL,
	[SourceName] [nvarchar](255) NULL,
	[SourceType] [nvarchar](255) NULL,
	[NoCertification] [nvarchar](255) NULL,
	[CertificationExternalNotes] [nvarchar](255) NULL,
	[LinkType] [nvarchar](255) NULL
) ON [PRIMARY]

GO


