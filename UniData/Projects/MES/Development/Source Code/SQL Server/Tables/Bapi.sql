USE [hydra_DataTransfer]
GO

/****** Object:  Table [trs].[Bapi]    Script Date: 03/03/2016 2:25:36 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [trs].[Bapi](
	[RecordID] [varchar](8) NOT NULL,
	[BapiPosition] [int] NOT NULL,
	[SyncObjectID] [varchar](25) NULL,
	[ActionCode] [varchar](50) NULL,
 CONSTRAINT [PK_Bapi] PRIMARY KEY CLUSTERED 
(
	[RecordID] ASC,
	[BapiPosition] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [trs].[Bapi]  WITH CHECK ADD  CONSTRAINT [FK_Bapi_Record] FOREIGN KEY([RecordID])
REFERENCES [trs].[Record] ([RecordID])
GO

ALTER TABLE [trs].[Bapi] CHECK CONSTRAINT [FK_Bapi_Record]
GO


