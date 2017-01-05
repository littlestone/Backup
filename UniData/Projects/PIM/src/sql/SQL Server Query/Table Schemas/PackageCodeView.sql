USE [DataWarehouse_PIM]
GO

/****** Object:  Table [dbo].[PackageCodeView]    Script Date: 01/04/2016 5:46:02 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PackageCodeView](
	[PackageCodeID] [nvarchar](255) NULL,
	[PackageType] [nvarchar](255) NULL,
	[PackageCode] [nvarchar](255) NULL,
	[IsActive] [nvarchar](255) NULL,
	[LongDescription] [nvarchar](255) NULL,
	[ShortDescription] [nvarchar](255) NULL,
	[Length] [nvarchar](255) NULL,
	[Width] [nvarchar](255) NULL,
	[Height] [nvarchar](255) NULL,
	[Weight] [nvarchar](255) NULL
) ON [PRIMARY]

GO


