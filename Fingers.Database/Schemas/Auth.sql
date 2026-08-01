/*
==============================================================================
Project      : Fingers
Module       : Authentication
Object Type  : Schema
Object Name  : auth
Author       : Mohd Suhail
Description  : Creates the authentication schema.
==============================================================================
*/

IF NOT EXISTS
(
    SELECT 1
    FROM sys.schemas
    WHERE name = 'auth'
)
BEGIN
    EXEC('CREATE SCHEMA auth');
END
GO