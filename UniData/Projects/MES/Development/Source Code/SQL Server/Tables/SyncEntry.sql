USE [hydra_DataTransfer]
GO

/****** Object:  Table [cfg].[SyncEntry]    Script Date: 03/03/2016 2:25:03 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [cfg].[SyncEntry](
	[SyncID] [varchar](5) NOT NULL,
	[FieldPosition] [int] NOT NULL,
	[FieldID] [varchar](50) NULL,
	[FieldName] [varchar](50) NULL,
	[DataType] [varchar](15) NULL,
 CONSTRAINT [PK_EntryString] PRIMARY KEY CLUSTERED 
(
	[SyncID] ASC,
	[FieldPosition] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [cfg].[SyncEntry]  WITH CHECK ADD  CONSTRAINT [FK_SyncEntry_Sync] FOREIGN KEY([SyncID])
REFERENCES [cfg].[Sync] ([SyncID])
GO

ALTER TABLE [cfg].[SyncEntry] CHECK CONSTRAINT [FK_SyncEntry_Sync]
GO


