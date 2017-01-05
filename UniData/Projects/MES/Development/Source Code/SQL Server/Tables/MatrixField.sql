USE [hydra_DataTransfer]
GO

/****** Object:  Table [trs].[MatrixField]    Script Date: 03/03/2016 2:25:58 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [trs].[MatrixField](
	[RequestID] [int] NULL,
	[DialogFileID] [varchar](100) NULL,
	[mleTrsID] [varchar](50) NULL,
	[MatrixRowID] [smallint] NULL,
	[MatrixFieldID] [int] NULL,
	[DataBefore] [varchar](800) NULL,
	[DataAfter] [varchar](800) NULL,
	[EntryFieldName] [varchar](50) NULL,
	[EntryDataType] [varchar](15) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


