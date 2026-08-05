CREATE TABLE chat.Conversations
(
    ConversationId BIGINT IDENTITY(1,1) NOT NULL,

    ConversationTypeId TINYINT NOT NULL,

    Title NVARCHAR(200) NULL,

    Description NVARCHAR(500) NULL,

    ConversationImageUrl NVARCHAR(500) NULL,

    IsActive BIT NOT NULL
        CONSTRAINT DF_chat_Conversations_IsActive
        DEFAULT(1),

    CreatedOn DATETIME2 NOT NULL
        CONSTRAINT DF_chat_Conversations_CreatedOn
        DEFAULT SYSUTCDATETIME(),

    CreatedByUserId BIGINT NOT NULL,

    ModifiedOn DATETIME2 NULL,

    ModifiedByUserId BIGINT NULL,

    CONSTRAINT PK_chat_Conversations
        PRIMARY KEY (ConversationId),

    CONSTRAINT FK_chat_Conversations_ConversationType
        FOREIGN KEY (ConversationTypeId)
        REFERENCES common.ConversationTypes(ConversationTypeId),

    CONSTRAINT FK_chat_Conversations_CreatedBy
        FOREIGN KEY (CreatedByUserId)
        REFERENCES auth.Users(UserId),

    CONSTRAINT FK_chat_Conversations_ModifiedBy
        FOREIGN KEY (ModifiedByUserId)
        REFERENCES auth.Users(UserId)
);
GO