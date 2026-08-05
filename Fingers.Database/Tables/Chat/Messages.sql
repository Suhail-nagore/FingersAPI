CREATE TABLE chat.Messages
(
    MessageId BIGINT IDENTITY(1,1) NOT NULL,

    ConversationId BIGINT NOT NULL,

    SenderUserId BIGINT NOT NULL,

    MessageTypeId TINYINT NOT NULL,

    ClientMessageId UNIQUEIDENTIFIER NOT NULL,

    Content NVARCHAR(MAX) NULL,

    ReplyToMessageId BIGINT NULL,

    ForwardedFromMessageId BIGINT NULL,

    EditedOn DATETIME2 NULL,

    EditedByUserId BIGINT NULL,

    DeletedOn DATETIME2 NULL,

    DeletedByUserId BIGINT NULL,

    SentOn DATETIME2 NOT NULL
        CONSTRAINT DF_chat_Messages_SentOn
        DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_chat_Messages
        PRIMARY KEY (MessageId),

    CONSTRAINT FK_chat_Messages_Conversation
        FOREIGN KEY (ConversationId)
        REFERENCES chat.Conversations(ConversationId),

    CONSTRAINT FK_chat_Messages_Sender
        FOREIGN KEY (SenderUserId)
        REFERENCES auth.Users(UserId),

    CONSTRAINT FK_chat_Messages_MessageType
        FOREIGN KEY (MessageTypeId)
        REFERENCES common.MessageTypes(MessageTypeId),

    CONSTRAINT FK_chat_Messages_Reply
        FOREIGN KEY (ReplyToMessageId)
        REFERENCES chat.Messages(MessageId),

    CONSTRAINT FK_chat_Messages_ForwardedMessage
        FOREIGN KEY (ForwardedFromMessageId)
        REFERENCES chat.Messages(MessageId),

    CONSTRAINT FK_chat_Messages_EditedBy
        FOREIGN KEY (EditedByUserId)
        REFERENCES auth.Users(UserId),

    CONSTRAINT FK_chat_Messages_DeletedBy
        FOREIGN KEY (DeletedByUserId)
        REFERENCES auth.Users(UserId),

    CONSTRAINT UQ_chat_Messages_ClientMessageId
        UNIQUE (ClientMessageId)
);
GO