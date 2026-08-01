/*
==============================================================================
Project      : Fingers
Module       : Audit
Object Type  : Schema
Object Name  : audit
Author       : Mohd Suhail
Description  : Creates the audit schema.
==============================================================================
*/

IF NOT EXISTS
(
    SELECT 1
    FROM sys.schemas
    WHERE name = 'audit'
)
BEGIN
    EXEC('CREATE SCHEMA audit');
END
GO