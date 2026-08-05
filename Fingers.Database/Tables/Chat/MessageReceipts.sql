CREATE TABLE chat.MessageReceipts
(
    MessageReceiptId BIGINT IDENTITY(1,1) NOT NULL,

    MessageId BIGINT NOT NULL,

    UserId BIGINT NOT NULL,

    DeliveredOn DATETIME2 NULL,

    ReadOn DATETIME2 NULL,

    CONSTRAINT PK_chat_MessageReceipts
        PRIMARY KEY (MessageReceiptId),

    CONSTRAINT FK_chat_MessageReceipts_Message
        FOREIGN KEY (MessageId)
        REFERENCES chat.Messages(MessageId),

    CONSTRAINT FK_chat_MessageReceipts_User
        FOREIGN KEY (UserId)
        REFERENCES auth.Users(UserId),

    CONSTRAINT UQ_chat_MessageReceipts
        UNIQUE (MessageId, UserId)
);
GO