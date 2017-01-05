USE [hydra_DataTransfer]
GO

/****** Object:  Table [trs].[Request]    Script Date: 03/03/2016 2:26:41 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [trs].[Request](
	[RequestID] [int] NOT NULL,
	[RequestInsertDate] [datetime] NULL,
	[RequestDate] [datetime] NULL,
	[JsonFileName] [varchar](100) NULL,
	[BapiFileName] [varchar](100) NULL,
	[DialogFileID] [varchar](100) NULL,
	[JsonDataString] [varchar](max) NULL,
	[TreeNodeList] [varchar](max) NULL,
	[RequestStatus] [varchar](3) NULL,
	[SyncID] [varchar](5) NULL,
	[RequestUserID] [varchar](50) NULL,
	[ProcessReturnCode] [int] NULL,
 CONSTRAINT [PK_Request] PRIMARY KEY CLUSTERED 
(
	[RequestID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


