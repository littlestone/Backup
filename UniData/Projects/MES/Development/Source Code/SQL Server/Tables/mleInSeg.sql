USE [hydra_DataTransfer]
GO

/****** Object:  Table [trs].[mleInSeg]    Script Date: 03/03/2016 2:26:11 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [trs].[mleInSeg](
	[mleTrsID] [varchar](50) NOT NULL,
	[SegPosition] [int] NOT NULL,
	[SegStatus] [varchar](5) NULL,
	[ErrorName] [varchar](100) NULL,
	[SegSaveDate] [datetime] NULL,
	[SegProcessDate] [datetime] NULL,
	[SegName] [varchar](50) NULL,
	[SegData] [varchar](5000) NULL,
	[SegKEY] [int] NULL,
 CONSTRAINT [PK_mleInSeg] PRIMARY KEY CLUSTERED 
(
	[mleTrsID] ASC,
	[SegPosition] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


