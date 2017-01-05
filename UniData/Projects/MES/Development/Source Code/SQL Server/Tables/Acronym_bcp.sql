USE [hydra_DataTransfer]
GO

/****** Object:  Table [cfg].[Acronym_bcp]    Script Date: 03/03/2016 2:23:51 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [cfg].[Acronym_bcp](
	[SyncObjectID] [varchar](25) NOT NULL,
	[AcronymSeq] [int] NOT NULL,
	[AcronymCode] [varchar](50) NULL,
	[AcronymName] [varchar](50) NULL,
	[BoilerPlate] [varchar](100) NULL,
	[TransformType] [varchar](10) NULL,
	[ExpresstionDataType] [varchar](15) NULL,
	[Usage] [varchar](15) NULL,
	[AcronymNote1] [varchar](100) NULL,
	[AcronymNote2] [varchar](100) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


