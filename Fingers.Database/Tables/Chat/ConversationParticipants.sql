CREATE TABLE chat.ConversationParticipants
(
    ConversationParticipantId BIGINT IDENTITY(1,1) NOT NULL,

    ConversationId BIGINT NOT NULL,

    UserId BIGINT NOT NULL,

    JoinedOn DATETIME2 NOT NULL
        CONSTRAINT DF_chat_ConversationParticipants_JoinedOn
        DEFAULT SYSUTCDATETIME(),

    LeftOn DATETIME2 NULL,

    LastDeliveredMessageId BIGINT NULL,

    LastReadMessageId BIGINT NULL,

    PinnedOn DATETIME2 NULL,

    HiddenOn DATETIME2 NULL,

    IsAdmin BIT NOT NULL
        CONSTRAINT DF_chat_ConversationParticipants_IsAdmin
        DEFAULT (0),

    IsMuted BIT NOT NULL
        CONSTRAINT DF_chat_ConversationParticipants_IsMuted
        DEFAULT (0),

    IsArchived BIT NOT NULL
        CONSTRAINT DF_chat_ConversationParticipants_IsArchived
        DEFAULT (0),

    CONSTRAINT PK_chat_ConversationParticipants
        PRIMARY KEY (ConversationParticipantId),

    CONSTRAINT FK_chat_ConversationParticipants_Conversation
        FOREIGN KEY (ConversationId)
        REFERENCES chat.Conversations (ConversationId),

    CONSTRAINT FK_chat_ConversationParticipants_User
        FOREIGN KEY (UserId)
        REFERENCES auth.Users (UserId),

    CONSTRAINT UQ_chat_ConversationParticipants
        UNIQUE (ConversationId, UserId)
);
GO

CREATE INDEX IX_chat_ConversationParticipants_UserId
ON chat.ConversationParticipants(UserId);
GO

CREATE INDEX IX_chat_ConversationParticipants_ConversationId
ON chat.ConversationParticipants(ConversationId);
GO