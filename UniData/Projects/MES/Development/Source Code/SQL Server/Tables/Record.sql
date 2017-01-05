USE [hydra_DataTransfer]
GO

/****** Object:  Table [trs].[Record]    Script Date: 03/03/2016 2:26:31 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [trs].[Record](
	[RequestID] [int] NOT NULL,
	[RecordPosition] [int] NOT NULL,
	[SyncID] [varchar](5) NULL,
	[RecordID] [varchar](8) NOT NULL,
	[ResultTypeID] [tinyint] NULL,
 CONSTRAINT [PK_Record] PRIMARY KEY CLUSTERED 
(
	[RecordID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


