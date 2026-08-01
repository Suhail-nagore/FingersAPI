/*
==============================================================================
Project      : Fingers
Module       : Administration
Object Type  : Schema
Object Name  : admin
Author       : Mohd Suhail
Description  : Creates the administration schema.
==============================================================================
*/

IF NOT EXISTS
(
    SELECT 1
    FROM sys.schemas
    WHERE name = 'admin'
)
BEGIN
    EXEC('CREATE SCHEMA admin');
END
GO