USE [DataWarehouse_PIM]
GO

/****** Object:  Table [dbo].[PIM_AllProductCodes]    Script Date: 2016-09-22 11:54:48 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[PIM_AllProductCodes](
	[ProductCode] [varchar](10) NOT NULL,
 CONSTRAINT [PK_PIM_AllProductCodes] PRIMARY KEY CLUSTERED 
(
	[ProductCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


