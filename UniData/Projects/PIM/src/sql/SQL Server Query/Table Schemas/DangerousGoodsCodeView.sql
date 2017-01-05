USE [DataWarehouse_PIM]
GO

/****** Object:  Table [dbo].[DangerousGoodsCodeView]    Script Date: 01/04/2016 5:44:52 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[DangerousGoodsCodeView](
	[DGCodeID] [nvarchar](255) NULL,
	[DGCode] [nvarchar](255) NULL,
	[DGCodeCode] [nvarchar](255) NULL,
	[Description] [nvarchar](255) NULL,
	[Message] [nvarchar](255) NULL,
	[PrintMessageOnBOL] [nvarchar](255) NULL,
	[UNCodes] [nvarchar](255) NULL,
	[UNCodeWeights] [nvarchar](255) NULL
) ON [PRIMARY]

GO


