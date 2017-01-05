USE [hydra_DataTransfer]
GO

/****** Object:  Table [cfg].[SyncAction]    Script Date: 03/03/2016 2:24:54 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [cfg].[SyncAction](
	[SyncID] [varchar](5) NOT NULL,
	[ResultTypeID] [tinyint] NOT NULL,
	[ActionSeq] [tinyint] NOT NULL,
	[SyncObjectID] [varchar](25) NULL,
	[ActionCode] [varchar](50) NULL,
 CONSTRAINT [PK_SyncCase] PRIMARY KEY CLUSTERED 
(
	[SyncID] ASC,
	[ResultTypeID] ASC,
	[ActionSeq] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [cfg].[SyncAction]  WITH CHECK ADD  CONSTRAINT [FK_SyncAction_ResultType] FOREIGN KEY([ResultTypeID])
REFERENCES [cfg].[ResultType] ([ResultTypeID])
GO

ALTER TABLE [cfg].[SyncAction] CHECK CONSTRAINT [FK_SyncAction_ResultType]
GO

ALTER TABLE [cfg].[SyncAction]  WITH CHECK ADD  CONSTRAINT [FK_SyncAction_SyncObject] FOREIGN KEY([SyncObjectID])
REFERENCES [cfg].[SyncObject] ([SyncObjectID])
GO

ALTER TABLE [cfg].[SyncAction] CHECK CONSTRAINT [FK_SyncAction_SyncObject]
GO

ALTER TABLE [cfg].[SyncAction]  WITH CHECK ADD  CONSTRAINT [FK_SyncCase_Sync] FOREIGN KEY([SyncID])
REFERENCES [cfg].[Sync] ([SyncID])
GO

ALTER TABLE [cfg].[SyncAction] CHECK CONSTRAINT [FK_SyncCase_Sync]
GO


