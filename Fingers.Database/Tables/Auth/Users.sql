/*
==============================================================================
Project      : Fingers
Module       : Authentication
Object Type  : Table
Object Name  : Users
Author       : Mohd Suhail
Description  : Stores registered users.
==============================================================================
*/

IF OBJECT_ID('auth.Users', 'U') IS NULL
BEGIN
    CREATE TABLE auth.Users
    (
        UserId              BIGINT IDENTITY(1,1) NOT NULL,

        UserName            NVARCHAR(50)         NOT NULL,

        DisplayName         NVARCHAR(100)        NOT NULL,

        Email               NVARCHAR(320)        NOT NULL,

        PasswordHash        NVARCHAR(MAX)        NOT NULL,

        UserStatusId        TINYINT              NOT NULL,

        IsActive            BIT                  NOT NULL
            CONSTRAINT DF_auth_Users_IsActive
            DEFAULT (1),

        CreatedOn           DATETIME2(7)         NOT NULL
            CONSTRAINT DF_auth_Users_CreatedOn
            DEFAULT (SYSUTCDATETIME()),

        CreatedByUserId     BIGINT               NULL,

        ModifiedOn          DATETIME2(7)         NULL,

        ModifiedByUserId    BIGINT               NULL,

        CONSTRAINT PK_auth_Users
            PRIMARY KEY CLUSTERED (UserId),

        CONSTRAINT UQ_auth_Users_Username
            UNIQUE (Username),

        CONSTRAINT UQ_auth_Users_Email
            UNIQUE (Email),

        CONSTRAINT FK_auth_Users_UserStatusId_common_UserStatuses
            FOREIGN KEY (UserStatusId)
            REFERENCES common.UserStatuses(UserStatusId)
    );
END;
GO