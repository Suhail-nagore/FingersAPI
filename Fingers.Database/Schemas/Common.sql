/*
==============================================================================
Project      : Fingers
Module       : Common
Object Type  : Schema
Object Name  : common
Author       : Mohd Suhail
Description  : Creates the common schema.
==============================================================================
*/

IF NOT EXISTS
(
    SELECT 1
    FROM sys.schemas
    WHERE name = 'common'
)
BEGIN
    EXEC('CREATE SCHEMA common');
END
GO