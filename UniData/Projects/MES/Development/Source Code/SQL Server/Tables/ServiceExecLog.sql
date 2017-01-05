USE [hydra_DataTransfer]
GO

/****** Object:  Table [dbo].[ServiceExecLog]    Script Date: 03/03/2016 2:25:26 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[ServiceExecLog](
	[id] [bigint] NOT NULL,
	[ServiceCode] [varchar](20) NULL,
	[LastRunDateTime] [datetime] NULL,
 CONSTRAINT [PK_svc_log] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


