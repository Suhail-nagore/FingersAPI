USE [ChatFingers]
GO

/****** Object:  StoredProcedure [chat].[SendMessage]    Script Date: 07-08-2026 11:56:51 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

Alter PROCEDURE [chat].[SendMessage]
(
    @SenderUserId BIGINT,
    @ReceiverUserId BIGINT,

    @ClientMessageId UNIQUEIDENTIFIER,

    @MessageTypeId TINYINT,

    @Content NVARCHAR(MAX) = NULL,

    @ReplyToMessageId BIGINT = NULL,

    @ForwardedFromMessageId BIGINT = NULL,

    @Attachments NVARCHAR(MAX) = NULL,

    @Success BIT OUTPUT,

    @Message NVARCHAR(500) OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    ----------------------------------------------------------------------
    -- Variables
    ----------------------------------------------------------------------

    DECLARE @AcceptedStatusId TINYINT;

    DECLARE @ConnectionStatusId TINYINT;

    DECLARE @ConnectionId BIGINT;

    DECLARE @ConversationId BIGINT;

    DECLARE @PrivateConversationTypeId TINYINT;

    DECLARE @NewMessageId BIGINT;

    DECLARE @SentOn DATETIME2;

    DECLARE @ExistingMessageId BIGINT;

    IF OBJECT_ID('tempdb..#Attachments') IS NOT NULL
    DROP TABLE #Attachments;

    CREATE TABLE #Attachments ( AttachmentId BIGINT PRIMARY KEY);

    BEGIN TRY

        BEGIN TRANSACTION;
        ----------------------------------------------------------------------
        -- Normalize
        ----------------------------------------------------------------------

        SET @Content = NULLIF(LTRIM(RTRIM(@Content)), '');

        ----------------------------------------------------------------------
        -- Parse Attachments
        ----------------------------------------------------------------------

        IF @Attachments IS NOT NULL
        BEGIN
            INSERT INTO #Attachments
            (
                AttachmentId
            )
            SELECT
                AttachmentId
            FROM OPENJSON(@Attachments)
            WITH
            (
                AttachmentId BIGINT '$.AttachmentId'
            );
        END;

        ----------------------------------------------------------------------
        -- Lookup Values
        ----------------------------------------------------------------------

        SELECT
            @AcceptedStatusId = ConnectionStatusId
        FROM common.tvfConnectionStatusGet('ACCEPTED');

        SELECT
            @PrivateConversationTypeId = ConversationTypeId
        FROM common.tvfConversationTypeGet('PRIVATE');


        ----------------------------------------------------------------------
        -- Validate Sender
        ----------------------------------------------------------------------

        IF NOT EXISTS
        (
            SELECT 1
            FROM auth.Users
            WHERE UserId = @SenderUserId
              AND IsActive = 1
        )
        BEGIN
            SET @Success = 0;
            SET @Message = 'Invalid sender.';

            ROLLBACK TRANSACTION;
            RETURN;
        END;

        ----------------------------------------------------------------------
        -- Validate Receiver
        ----------------------------------------------------------------------

        IF NOT EXISTS
        (
            SELECT 1
            FROM auth.Users
            WHERE UserId = @ReceiverUserId
              AND IsActive = 1
        )
        BEGIN
            SET @Success = 0;
            SET @Message = 'Receiver not found.';

            ROLLBACK TRANSACTION;
            RETURN;
        END;

        ----------------------------------------------------------------------
        -- Sender Cannot Message Himself
        ----------------------------------------------------------------------

        IF @SenderUserId = @ReceiverUserId
        BEGIN
            SET @Success = 0;
            SET @Message = 'You cannot send messages to yourself.';

            ROLLBACK TRANSACTION;
            RETURN;
        END;

        ----------------------------------------------------------------------
        -- Load Connection
        ----------------------------------------------------------------------

        SELECT TOP (1)
            @ConnectionId = ConnectionId,
            @ConnectionStatusId = ConnectionStatusId
        FROM chat.UserConnections
        WHERE
        (
            SenderUserId = @SenderUserId
            AND ReceiverUserId = @ReceiverUserId
        )
        OR
        (
            SenderUserId = @ReceiverUserId
            AND ReceiverUserId = @SenderUserId
        );

        ----------------------------------------------------------------------
        -- Connection Exists
        ----------------------------------------------------------------------

        IF @ConnectionId IS NULL
        BEGIN
            SET @Success = 0;
            SET @Message = 'You are not connected with this user.';

            ROLLBACK TRANSACTION;
            RETURN;
        END;

        ----------------------------------------------------------------------
        -- Connection Status
        ----------------------------------------------------------------------

        IF @ConnectionStatusId <> @AcceptedStatusId
        BEGIN
            SET @Success = 0;
            SET @Message = 'You can only send messages to accepted connections.';

            ROLLBACK TRANSACTION;
            RETURN;
        END;

        ----------------------------------------------------------------------
        -- Duplicate Client Message
        ----------------------------------------------------------------------

SELECT
    @ExistingMessageId = MessageId
FROM chat.Messages
WHERE ClientMessageId = @ClientMessageId;

IF @ExistingMessageId IS NOT NULL
BEGIN
    COMMIT TRANSACTION;

    SET @Success = 1;
    SET @Message = 'Message already processed.';

    RETURN;
END;

        ----------------------------------------------------------------------
        -- Validate Attachments
        ----------------------------------------------------------------------

        IF EXISTS
        (
            SELECT 1
            FROM #Attachments A
            LEFT JOIN chat.MessageAttachments MA
                ON MA.MessageAttachmentId = A.AttachmentId
            WHERE
                MA.MessageAttachmentId IS NULL
                OR MA.UploadedByUserId <> @SenderUserId
                OR MA.MessageId IS NOT NULL
        )
        BEGIN
            SET @Success = 0;
            SET @Message = 'One or more attachments are invalid.';

            ROLLBACK TRANSACTION;
            RETURN;
        END;

        

        ----------------------------------------------------------------------
        -- Validate Message Type
        ----------------------------------------------------------------------

        IF NOT EXISTS
        (
            SELECT 1
            FROM common.MessageTypes
            WHERE MessageTypeId = @MessageTypeId
        )
        BEGIN
            SET @Success = 0;
            SET @Message = 'Invalid message type.';

            ROLLBACK TRANSACTION;
            RETURN;
        END;

        ----------------------------------------------------------------------
        -- Find Existing Private Conversation
        ----------------------------------------------------------------------

SELECT TOP (1)
    @ConversationId = CP1.ConversationId
FROM chat.ConversationParticipants CP1 WITH (UPDLOCK, HOLDLOCK)
INNER JOIN chat.ConversationParticipants CP2
    ON CP1.ConversationId = CP2.ConversationId
INNER JOIN chat.Conversations C
    ON C.ConversationId = CP1.ConversationId
WHERE
    C.ConversationTypeId = @PrivateConversationTypeId
    AND CP1.UserId = @SenderUserId
    AND CP2.UserId = @ReceiverUserId
    AND CP1.LeftOn IS NULL
    AND CP2.LeftOn IS NULL
    AND
    (
        SELECT COUNT(*)
        FROM chat.ConversationParticipants P
        WHERE
            P.ConversationId = C.ConversationId
            AND P.LeftOn IS NULL
    ) = 2
ORDER BY
    CP1.ConversationId;

        ----------------------------------------------------------------------
        -- Create Conversation
        ----------------------------------------------------------------------

        IF @ConversationId IS NULL
        BEGIN

            DECLARE @Conversation TABLE
            (
                ConversationId BIGINT
            );

            INSERT INTO chat.Conversations
            (
                ConversationTypeId,
                Title,
                Description,
                ConversationImageUrl,
                CreatedByUserId
            )
            OUTPUT INSERTED.ConversationId
            INTO @Conversation
            VALUES
                (
                    @PrivateConversationTypeId,
                    NULL,
                    NULL,
                    NULL,
                    @SenderUserId
                );

            SELECT
                @ConversationId = ConversationId
            FROM @Conversation;


            INSERT INTO chat.ConversationParticipants ( ConversationId, UserId)
            VALUES ( @ConversationId,@SenderUserId),(@ConversationId,@ReceiverUserId);
        END;

        ----------------------------------------------------------------------
-- Validate Reply Message
----------------------------------------------------------------------

IF @ReplyToMessageId IS NOT NULL
BEGIN
    IF NOT EXISTS
    (
        SELECT 1
        FROM chat.Messages
        WHERE MessageId = @ReplyToMessageId
          AND ConversationId = @ConversationId
    )
    BEGIN
        SET @Success = 0;
        SET @Message = 'Reply message does not belong to this conversation.';

        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;

       ----------------------------------------------------------------------
-- Validate Forwarded Message
----------------------------------------------------------------------

IF @ForwardedFromMessageId IS NOT NULL
BEGIN
    IF NOT EXISTS
    (
        SELECT 1
        FROM chat.Messages
        WHERE MessageId = @ForwardedFromMessageId
          AND ConversationId = @ConversationId
    )
    BEGIN
        SET @Success = 0;
        SET @Message = 'Forwarded message does not belong to this conversation.';

        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;

----------------------------------------------------------------------
-- Copy Forwarded Message Content
----------------------------------------------------------------------

IF @ForwardedFromMessageId IS NOT NULL
BEGIN
    SELECT
        @Content = Content,
        @MessageTypeId = MessageTypeId
    FROM chat.Messages
    WHERE MessageId = @ForwardedFromMessageId;
END;


 ----------------------------------------------------------------------
        -- Validate Message Content
        ----------------------------------------------------------------------

        IF @Content IS NULL
           AND NOT EXISTS
           (
               SELECT 1
               FROM #Attachments
           )
        BEGIN
            SET @Success = 0;
            SET @Message = 'Message content or attachment is required.';

            ROLLBACK TRANSACTION;
            RETURN;
        END;
----------------------------------------------------------------------
-- Insert Message
----------------------------------------------------------------------

DECLARE @InsertedMessage TABLE
(
    MessageId BIGINT,
    SentOn DATETIME2
);

INSERT INTO chat.Messages
(
    ConversationId,
    SenderUserId,
    MessageTypeId,
    ClientMessageId,
    Content,
    ReplyToMessageId,
    ForwardedFromMessageId
)
OUTPUT
    INSERTED.MessageId,
    INSERTED.SentOn
INTO @InsertedMessage
VALUES
(
    @ConversationId,
    @SenderUserId,
    @MessageTypeId,
    @ClientMessageId,
    @Content,
    @ReplyToMessageId,
    @ForwardedFromMessageId
);

SELECT
    @NewMessageId = MessageId,
    @SentOn = SentOn
FROM @InsertedMessage;


----------------------------------------------------------------------
-- Attach Files
----------------------------------------------------------------------

UPDATE MA
SET
    MessageId = @NewMessageId
FROM chat.MessageAttachments MA
INNER JOIN #Attachments A
    ON A.AttachmentId = MA.MessageAttachmentId;


    ----------------------------------------------------------------------
-- Create Message Receipts
----------------------------------------------------------------------

INSERT INTO chat.MessageReceipts
(
    MessageId,
    UserId,
    DeliveredOn,
    ReadOn
)
VALUES
(
    @NewMessageId,
    @ReceiverUserId,
    NULL,
    NULL
);

----------------------------------------------------------------------
-- Commit
----------------------------------------------------------------------

COMMIT TRANSACTION;

SET @Success = 1;

SET @Message = 'Message sent successfully.';
SELECT
    MessageId,
    ConversationId,
    SenderUserId,
    ClientMessageId,
    MessageTypeId,
    Content,
    ReplyToMessageId,
    ForwardedFromMessageId,
    SentOn
FROM chat.Messages
WHERE MessageId = @NewMessageId;

END TRY

BEGIN CATCH

    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    IF ERROR_NUMBER() IN (2601, 2627)
    BEGIN
        SET @Success = 1;
        SET @Message = 'Message already processed.';
        RETURN;
    END;

    SET @Success = 0;
    SET @Message = ERROR_MESSAGE();

END CATCH

END
GO


