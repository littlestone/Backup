USE [hydra_DataTransfer]
GO

/****** Object:  Table [cfg].[Acronym]    Script Date: 03/03/2016 2:22:19 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [cfg].[Acronym](
	[SyncObjectID] [varchar](25) NOT NULL,
	[AcronymSeq] [int] NOT NULL,
	[AcronymCode] [varchar](50) NULL,
	[AcronymName] [varchar](50) NULL,
	[BoilerPlate] [varchar](100) NULL,
	[TransformType] [varchar](10) NULL,
	[ExpresstionDataType] [varchar](15) NULL,
	[Usage] [varchar](15) NULL,
	[AcronymNote1] [varchar](100) NULL,
	[AcronymNote2] [varchar](100) NULL,
 CONSTRAINT [PK_Acronym] PRIMARY KEY CLUSTERED 
(
	[SyncObjectID] ASC,
	[AcronymSeq] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [cfg].[Acronym]  WITH CHECK ADD  CONSTRAINT [FK_Acronym_SyncObject] FOREIGN KEY([SyncObjectID])
REFERENCES [cfg].[SyncObject] ([SyncObjectID])
GO

ALTER TABLE [cfg].[Acronym] CHECK CONSTRAINT [FK_Acronym_SyncObject]
GO


