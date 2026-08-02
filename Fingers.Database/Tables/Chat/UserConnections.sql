IF OBJECT_ID('chat.UserConnections', 'U') IS NULL
BEGIN
    CREATE TABLE chat.UserConnections
    (
        ConnectionId            BIGINT IDENTITY(1,1) NOT NULL,

        SenderUserId            BIGINT              NOT NULL,

        ReceiverUserId          BIGINT              NOT NULL,

        ConnectionStatusId      TINYINT             NOT NULL,

        CreatedOn               DATETIME2(7)        NOT NULL
            CONSTRAINT DF_chat_UserConnections_CreatedOn
            DEFAULT (SYSUTCDATETIME()),

        CreatedByUserId         BIGINT              NOT NULL,

        ModifiedOn              DATETIME2(7)        NULL,

        ModifiedByUserId        BIGINT              NULL,

        CONSTRAINT PK_chat_UserConnections
            PRIMARY KEY CLUSTERED (ConnectionId),

        CONSTRAINT FK_chat_UserConnections_SenderUser
            FOREIGN KEY (SenderUserId)
            REFERENCES auth.Users(UserId),

        CONSTRAINT FK_chat_UserConnections_ReceiverUser
            FOREIGN KEY (ReceiverUserId)
            REFERENCES auth.Users(UserId),

        CONSTRAINT FK_chat_UserConnections_Status
            FOREIGN KEY (ConnectionStatusId)
            REFERENCES common.ConnectionStatuses(ConnectionStatusId),

        CONSTRAINT FK_chat_UserConnections_CreatedBy
            FOREIGN KEY (CreatedByUserId)
            REFERENCES auth.Users(UserId),

        CONSTRAINT FK_chat_UserConnections_ModifiedBy
            FOREIGN KEY (ModifiedByUserId)
            REFERENCES auth.Users(UserId),

        CONSTRAINT CHK_chat_UserConnections_NoSelfConnection
            CHECK (SenderUserId <> ReceiverUserId)
    );
END;
GO