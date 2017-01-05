USE [hydra_DataTransfer]
GO

/****** Object:  Table [cfg].[HydraObject]    Script Date: 03/03/2016 2:24:14 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [cfg].[HydraObject](
	[HydraObjectID] [varchar](25) NOT NULL,
	[ObjectName] [varchar](50) NULL,
	[TechName] [varchar](25) NULL,
 CONSTRAINT [PK_HydraObject] PRIMARY KEY CLUSTERED 
(
	[HydraObjectID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


