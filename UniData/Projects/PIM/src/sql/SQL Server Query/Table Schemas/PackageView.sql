USE [DataWarehouse_PIM]
GO

/****** Object:  Table [dbo].[PackageView]    Script Date: 01/04/2016 5:46:13 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PackageView](
	[PackageID] [nvarchar](255) NULL,
	[PackageCodeID] [nvarchar](255) NULL,
	[I2OF5] [nvarchar](255) NULL,
	[IsDefaultOption] [nvarchar](255) NULL,
	[IsDefaultBranch] [nvarchar](255) NULL,
	[Quantity] [nvarchar](255) NULL,
	[Length] [nvarchar](255) NULL,
	[Width] [nvarchar](255) NULL,
	[Height] [nvarchar](255) NULL,
	[Weight] [nvarchar](255) NULL,
	[PerTruckLoad] [nvarchar](255) NULL,
	[ChildID] [nvarchar](255) NULL,
	[ChildType] [nvarchar](255) NULL,
	[Child] [nvarchar](255) NULL
) ON [PRIMARY]

GO


