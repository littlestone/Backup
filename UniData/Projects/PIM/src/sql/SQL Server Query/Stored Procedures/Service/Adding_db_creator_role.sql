USE [PIM_QA]
GO

/****** Object:  DatabaseRole [db_executor]    Script Date: 2016-11-21 5:50:24 PM ******/
-- Create a db_executor role
CREATE ROLE db_executor

-- Grant execute rights to the new role
GRANT EXECUTE TO db_executor

-- to allocate a user to the new role :
EXEC sp_addrolemember 'db_executor','sqlPIMUser'
GO


