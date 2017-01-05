USE [hydra_DataTransfer]
GO

/****** Object:  Table [cfg].[ResultType]    Script Date: 03/03/2016 2:24:28 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [cfg].[ResultType](
	[ResultTypeID] [tinyint] NOT NULL,
	[ResultTypeName] [varchar](50) NULL,
	[ResultTypeDescription] [varchar](200) NULL,
 CONSTRAINT [PK_Case] PRIMARY KEY CLUSTERED 
(
	[ResultTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


