/*
==============================================================================
Project      : Fingers
Module       : Notification
Object Type  : Schema
Object Name  : notification
Author       : Mohd Suhail
Description  : Creates the notification schema.
==============================================================================
*/

IF NOT EXISTS
(
    SELECT 1
    FROM sys.schemas
    WHERE name = 'notification'
)
BEGIN
    EXEC('CREATE SCHEMA notification');
END
GO