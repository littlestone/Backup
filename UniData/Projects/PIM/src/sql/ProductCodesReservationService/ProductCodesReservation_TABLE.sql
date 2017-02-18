USE [DataWarehouse_PIM]
GO

/****** Object:  Table [dbo].[ProductCodesReservation]    Script Date: 2016-09-22 11:54:22 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[ProductCodesReservation](
	[ProductCode] [varchar](10) NOT NULL,
	[StatusCode] [int] NULL,
	[SourceCode] [varchar](1) NULL,
	[ts] [smalldatetime] NULL,
 CONSTRAINT [PK_PIM_ReserveProductCode] PRIMARY KEY CLUSTERED 
(
	[ProductCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


