USE [hydra_DataTransfer]
GO

/****** Object:  Table [trs].[DialogFile]    Script Date: 03/03/2016 2:25:48 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [trs].[DialogFile](
	[DialogFileID] [varchar](100) NOT NULL,
	[DialogFileDate] [datetime] NULL,
	[DialogFileName] [varchar](100) NULL,
	[DialogFileStatus] [varchar](3) NULL,
	[RequestCount] [int] NULL,
	[DialogCount] [int] NULL,
	[mleTrsID] [varchar](50) NULL,
 CONSTRAINT [PK_DialogFile] PRIMARY KEY CLUSTERED 
(
	[DialogFileID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


