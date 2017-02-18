USE [PIM_LIVE]
GO

/****** Object:  User [sqlPIMUser]    Script Date: 2017-01-10 8:04:28 AM ******/
-- Create a db_executor role
CREATE ROLE db_executor

--Grant execute rights to the new role
GRANT EXECUTE TO db_executor

-- to allocate a user to the new role :
EXEC sp_addrolemember 'db_executor','sqlPIMUser'

GO


