USE [hydra_DataTransfer]
GO

/****** Object:  Table [cfg].[SyncObject]    Script Date: 03/03/2016 2:25:16 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [cfg].[SyncObject](
	[SyncObjectID] [varchar](25) NOT NULL,
	[SyncID] [varchar](5) NULL,
	[HydraObjectID] [varchar](25) NULL,
 CONSTRAINT [PK_ProcessObject] PRIMARY KEY CLUSTERED 
(
	[SyncObjectID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [cfg].[SyncObject]  WITH CHECK ADD  CONSTRAINT [FK_SyncObject_HydraObject] FOREIGN KEY([HydraObjectID])
REFERENCES [cfg].[HydraObject] ([HydraObjectID])
GO

ALTER TABLE [cfg].[SyncObject] CHECK CONSTRAINT [FK_SyncObject_HydraObject]
GO

ALTER TABLE [cfg].[SyncObject]  WITH CHECK ADD  CONSTRAINT [FK_SyncObject_Sync] FOREIGN KEY([SyncID])
REFERENCES [cfg].[Sync] ([SyncID])
GO

ALTER TABLE [cfg].[SyncObject] CHECK CONSTRAINT [FK_SyncObject_Sync]
GO


