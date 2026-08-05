CREATE TABLE chat.MessageAttachments
(
    MessageAttachmentId BIGINT IDENTITY(1,1) NOT NULL,

    MessageId BIGINT NOT NULL,

    FileName NVARCHAR(255) NOT NULL,

    OriginalFileName NVARCHAR(255) NOT NULL,

    ContentType NVARCHAR(100) NOT NULL,

    FileExtension NVARCHAR(20) NOT NULL,

    FileSize BIGINT NOT NULL,

    StoragePath NVARCHAR(1000) NOT NULL,

    ThumbnailPath NVARCHAR(1000) NULL,

    DurationInSeconds INT NULL,

    Width INT NULL,

    Height INT NULL,

    CreatedOn DATETIME2 NOT NULL
        CONSTRAINT DF_chat_MessageAttachments_CreatedOn
        DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_chat_MessageAttachments
        PRIMARY KEY (MessageAttachmentId),

    CONSTRAINT FK_chat_MessageAttachments_Message
        FOREIGN KEY (MessageId)
        REFERENCES chat.Messages(MessageId)
);
GO