CREATE OR ALTER PROCEDURE chat.MarkMessagesRead
(
    @CurrentUserId BIGINT,
    @ConversationId BIGINT,
    @LastReadMessageId BIGINT,

    @Success BIT OUTPUT,
    @Message NVARCHAR(500) OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @ReadOn DATETIME2 = SYSUTCDATETIME();

    BEGIN TRY

        ----------------------------------------------------------------------
        -- Validate User
        ----------------------------------------------------------------------

        IF NOT EXISTS
        (
            SELECT 1
            FROM auth.Users
            WHERE UserId = @CurrentUserId
              AND IsActive = 1
        )
        BEGIN
            SET @Success = 0;
            SET @Message = 'Invalid user.';
            RETURN;
        END;


        ----------------------------------------------------------------------
        -- Validate Conversation
        ----------------------------------------------------------------------

        IF NOT EXISTS
        (
            SELECT 1
            FROM chat.Conversations
            WHERE ConversationId = @ConversationId
        )
        BEGIN
            SET @Success = 0;
            SET @Message = 'Conversation not found.';
            RETURN;
        END;


        ----------------------------------------------------------------------
        -- Validate Participant
        ----------------------------------------------------------------------

        IF NOT EXISTS
        (
            SELECT 1
            FROM chat.ConversationParticipants
            WHERE ConversationId = @ConversationId
              AND UserId = @CurrentUserId
              AND LeftOn IS NULL
        )
        BEGIN
            SET @Success = 0;
            SET @Message = 'You are not a participant of this conversation.';
            RETURN;
        END;


        ----------------------------------------------------------------------
        -- Validate Last Read Message
        ----------------------------------------------------------------------

        IF NOT EXISTS
        (
            SELECT 1
            FROM chat.Messages
            WHERE MessageId = @LastReadMessageId
              AND ConversationId = @ConversationId
        )
        BEGIN
            SET @Success = 0;
            SET @Message = 'Message does not belong to this conversation.';
            RETURN;
        END;


        ----------------------------------------------------------------------
        -- Mark Messages As Read
        --
        -- IMPORTANT:
        -- Reading a message implies that it has been delivered.
        --
        -- Therefore:
        --
        -- DeliveredOn = existing DeliveredOn
        --               OR current timestamp if NULL
        --
        -- ReadOn = existing ReadOn
        --          OR current timestamp if NULL
        ----------------------------------------------------------------------

        UPDATE MR
        SET
            DeliveredOn = COALESCE(
                MR.DeliveredOn,
                @ReadOn
            ),

            ReadOn = COALESCE(
                MR.ReadOn,
                @ReadOn
            )

        FROM chat.MessageReceipts MR

        INNER JOIN chat.Messages M
            ON M.MessageId = MR.MessageId

        WHERE
            MR.UserId = @CurrentUserId

            AND M.ConversationId = @ConversationId

            AND M.MessageId <= @LastReadMessageId

            AND M.SenderUserId <> @CurrentUserId

            AND MR.ReadOn IS NULL;


        ----------------------------------------------------------------------
        -- Update Conversation Participant Read Position
        ----------------------------------------------------------------------

        UPDATE CP
        SET
            LastReadMessageId = @LastReadMessageId

        FROM chat.ConversationParticipants CP

        WHERE
            CP.ConversationId = @ConversationId
            AND CP.UserId = @CurrentUserId
            AND CP.LeftOn IS NULL;


        ----------------------------------------------------------------------
        -- Success
        ----------------------------------------------------------------------

        SET @Success = 1;
        SET @Message = 'Messages marked as read.';

    END TRY

    BEGIN CATCH

        SET @Success = 0;
        SET @Message = ERROR_MESSAGE();

    END CATCH
END;
GO