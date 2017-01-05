USE [hydra_DataTransfer]
GO

/****** Object:  Table [trs].[mleInTrs]    Script Date: 03/03/2016 2:26:22 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [trs].[mleInTrs](
	[mleTrsID] [varchar](50) NOT NULL,
	[TrsStatus] [varchar](5) NULL,
	[TrsSegCount] [int] NULL,
	[TrsSegDone] [int] NULL,
	[TrsSegUnknown] [int] NULL,
	[TrsSegError] [int] NULL,
	[TrsSaveDate] [datetime] NULL,
	[TrsProcessDate] [datetime] NULL,
	[mleDocNo] [varchar](50) NULL,
	[mleFileType] [varchar](50) NULL,
	[dataFileName] [varchar](50) NULL,
	[errorFileName] [varchar](50) NULL,
	[TrsKEY] [int] NULL,
 CONSTRAINT [PK_mleInbound] PRIMARY KEY CLUSTERED 
(
	[mleTrsID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


