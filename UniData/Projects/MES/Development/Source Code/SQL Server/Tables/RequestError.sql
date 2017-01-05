USE [hydra_DataTransfer]
GO

/****** Object:  Table [trs].[RequestError]    Script Date: 03/03/2016 2:26:50 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [trs].[RequestError](
	[DialogFileID] [varchar](100) NULL,
	[ErrorDate] [datetime] NULL,
	[ErrorNumber] [int] NULL,
	[ErrorSeverity] [int] NULL,
	[ErrorState] [int] NULL,
	[ErrorProcedure] [nvarchar](128) NULL,
	[ErrorLine] [int] NULL,
	[ErrorMessage] [nvarchar](4000) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


