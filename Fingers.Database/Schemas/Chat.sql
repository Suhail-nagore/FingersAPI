/*
==============================================================================
Project      : Fingers
Module       : Chat
Object Type  : Schema
Object Name  : chat
Author       : Mohd Suhail
Description  : Creates the chat schema.
==============================================================================
*/

IF NOT EXISTS
(
    SELECT 1
    FROM sys.schemas
    WHERE name = 'chat'
)
BEGIN
    EXEC('CREATE SCHEMA chat');
END
GO