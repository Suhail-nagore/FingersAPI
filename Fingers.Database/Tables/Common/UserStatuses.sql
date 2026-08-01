/*
==============================================================================
Project      : Fingers
Module       : Common
Object Type  : Table
Object Name  : UserStatuses
Author       : Mohd Suhail
Description  : Stores all available user account statuses.
==============================================================================
*/

IF OBJECT_ID('common.UserStatuses', 'U') IS NULL
BEGIN
    CREATE TABLE common.UserStatuses
    (
        UserStatusId      TINYINT        NOT NULL,
        StatusCode        NVARCHAR(50)   NOT NULL,
        StatusName        NVARCHAR(100)  NOT NULL,
        Description       NVARCHAR(500)  NULL,
        DisplayOrder      INT            NOT NULL,
        IsActive          BIT            NOT NULL
            CONSTRAINT DF_common_UserStatuses_IsActive DEFAULT (1),

        CreatedOn         DATETIME2(7)   NOT NULL
            CONSTRAINT DF_common_UserStatuses_CreatedOn DEFAULT (SYSUTCDATETIME()),

        ModifiedOn        DATETIME2(7)   NULL,

        CONSTRAINT PK_common_UserStatuses
            PRIMARY KEY CLUSTERED (UserStatusId),

        CONSTRAINT UQ_common_UserStatuses_StatusCode
            UNIQUE (StatusCode)
    );
END;
GO