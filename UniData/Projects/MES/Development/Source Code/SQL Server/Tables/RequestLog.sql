USE [hydra_DataTransfer]
GO

/****** Object:  Table [trs].[RequestLog]    Script Date: 03/03/2016 2:26:59 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [trs].[RequestLog](
	[RequestLogID] [int] IDENTITY(1,1) NOT NULL,
	[RequestLogDate] [datetime] NULL,
	[JsonFileName] [varchar](100) NULL,
	[BapiFileName] [varchar](100) NULL,
	[BapiFileLineCount] [int] NULL,
	[JsonDataSting] [nvarchar](max) NULL,
	[TreeNodeList] [nvarchar](max) NULL,
	[RequestStatusCode] [int] NULL,
	[RequestLogError] [int] NULL,
 CONSTRAINT [PK_RequestLog] PRIMARY KEY CLUSTERED 
(
	[RequestLogID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [trs].[RequestLog] ADD  CONSTRAINT [DF_RequestLog_RequestLogError]  DEFAULT ((0)) FOR [RequestLogError]
GO


