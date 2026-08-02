IF OBJECT_ID('common.ConnectionStatuses', 'U') IS NULL
BEGIN
    CREATE TABLE common.ConnectionStatuses
    (
        ConnectionStatusId    TINYINT        NOT NULL,

        StatusCode            NVARCHAR(50)   NOT NULL,

        StatusName            NVARCHAR(100)  NOT NULL,

        Description           NVARCHAR(500)  NULL,

        DisplayOrder          INT            NOT NULL,

        IsActive              BIT            NOT NULL
            CONSTRAINT DF_common_ConnectionStatuses_IsActive DEFAULT(1),

        CreatedOn             DATETIME2(7)   NOT NULL
            CONSTRAINT DF_common_ConnectionStatuses_CreatedOn DEFAULT(SYSUTCDATETIME()),

        ModifiedOn            DATETIME2(7)   NULL,

        CONSTRAINT PK_common_ConnectionStatuses
            PRIMARY KEY(ConnectionStatusId),

        CONSTRAINT UQ_common_ConnectionStatuses_StatusCode
            UNIQUE(StatusCode)
    );
END;
GO