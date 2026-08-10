CREATE OR ALTER PROCEDURE chat.MessagesGet
(
    @CurrentUserId BIGINT,
    @ConversationId BIGINT,
    @BeforeMessageId BIGINT = NULL,
    @PageSize INT = 50
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY

        ----------------------------------------------------------------------
        -- Normalize Page Size
        ----------------------------------------------------------------------

        IF @PageSize IS NULL OR @PageSize <= 0
            SET @PageSize = 50;

        IF @PageSize > 100
            SET @PageSize = 100;


        ----------------------------------------------------------------------
        -- Validate Current User
        ----------------------------------------------------------------------

        IF NOT EXISTS
        (
            SELECT 1
            FROM auth.Users
            WHERE UserId = @CurrentUserId
              AND IsActive = 1
        )
        BEGIN
            THROW 50001, 'Invalid user.', 1;
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
            THROW 50002, 'Conversation not found.', 1;
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
            THROW 50003, 'You are not a participant of this conversation.', 1;
        END;


        ----------------------------------------------------------------------
        -- Get Page
        --
        -- We fetch PageSize + 1 messages.
        --
        -- Example:
        -- PageSize = 50
        --
        -- Fetch 51 messages.
        -- If 51 exists -> HasMore = 1
        -- Return only first 50.
        ----------------------------------------------------------------------

        ;WITH PageMessages AS
        (
            SELECT TOP (@PageSize + 1)

                M.MessageId,

                M.ConversationId,

                M.SenderUserId,

                Sender.UserName AS SenderUserName,

                Sender.DisplayName AS SenderDisplayName,

                Sender.ProfilePictureUrl AS SenderProfilePictureUrl,

                M.MessageTypeId,

                M.Content,

                M.ReplyToMessageId,

                M.ForwardedFromMessageId,

                M.EditedOn,

                M.EditedByUserId,

                M.DeletedOn,

                M.DeletedByUserId,

                M.SentOn,

                ROW_NUMBER() OVER
                (
                    ORDER BY M.MessageId DESC
                ) AS RowNumber

            FROM chat.Messages M

            INNER JOIN auth.Users Sender
                ON Sender.UserId = M.SenderUserId

            WHERE
                M.ConversationId = @ConversationId

                AND
                (
                    @BeforeMessageId IS NULL
                    OR M.MessageId < @BeforeMessageId
                )

            ORDER BY
                M.MessageId DESC
        )

        SELECT

            ------------------------------------------------------------------
            -- Message
            ------------------------------------------------------------------

            PM.MessageId,

            PM.ConversationId,

            PM.SenderUserId,

            PM.SenderUserName,

            PM.SenderDisplayName,

            PM.SenderProfilePictureUrl,

            PM.MessageTypeId,

            ------------------------------------------------------------------
            -- Content
            --
            -- Deleted messages do not expose their original content.
            ------------------------------------------------------------------

            CASE
                WHEN PM.DeletedOn IS NULL
                    THEN PM.Content
                ELSE NULL
            END AS Content,

            ------------------------------------------------------------------
            -- Reply Information
            ------------------------------------------------------------------

            PM.ReplyToMessageId,

            ReplyMessage.Content AS ReplyToContent,

            ReplyMessage.SenderUserId AS ReplyToSenderUserId,

            ReplySender.DisplayName AS ReplyToSenderDisplayName,

            ReplyMessage.MessageTypeId AS ReplyToMessageTypeId,

            ------------------------------------------------------------------
            -- Forward Information
            ------------------------------------------------------------------

            PM.ForwardedFromMessageId,

            ForwardedMessage.Content AS ForwardedContent,

            ForwardedMessage.SenderUserId AS ForwardedSenderUserId,

            ForwardedSender.DisplayName AS ForwardedSenderDisplayName,

            ForwardedMessage.MessageTypeId AS ForwardedMessageTypeId,

            ------------------------------------------------------------------
            -- Edit Information
            ------------------------------------------------------------------

            PM.EditedOn,

            PM.EditedByUserId,

            CASE
                WHEN PM.EditedOn IS NOT NULL
                    THEN CAST(1 AS BIT)
                ELSE CAST(0 AS BIT)
            END AS IsEdited,

            ------------------------------------------------------------------
            -- Delete Information
            ------------------------------------------------------------------

            PM.DeletedOn,

            PM.DeletedByUserId,

            CASE
                WHEN PM.DeletedOn IS NOT NULL
                    THEN CAST(1 AS BIT)
                ELSE CAST(0 AS BIT)
            END AS IsDeleted,

            ------------------------------------------------------------------
            -- Sent
            ------------------------------------------------------------------

            PM.SentOn,

            ------------------------------------------------------------------
            -- Attachments
            ------------------------------------------------------------------

            ISNULL
            (
                (
                    SELECT

                        MA.MessageAttachmentId AS AttachmentId,

                        MA.FileName,

                        MA.OriginalFileName,

                        MA.ContentType,

                        MA.FileExtension,

                        MA.FileSize,

                        MA.StoragePath,

                        MA.ThumbnailPath,

                        MA.DurationInSeconds,

                        MA.Width,

                        MA.Height,

                        MA.UploadedOn,

                        MA.UploadedByUserId

                    FROM chat.MessageAttachments MA

                    WHERE
                        MA.MessageId = PM.MessageId

                    ORDER BY
                        MA.MessageAttachmentId

                    FOR JSON PATH
                ),
                '[]'
            ) AS AttachmentsJson,

            ------------------------------------------------------------------
            -- Message Receipts
            --
            -- Works for private and group conversations.
            ------------------------------------------------------------------

            ISNULL
            (
                (
                    SELECT

                        MR.MessageReceiptId,

                        MR.UserId,

                        MR.DeliveredOn,

                        MR.ReadOn,

                        CASE
                            WHEN MR.DeliveredOn IS NOT NULL
                                THEN CAST(1 AS BIT)
                            ELSE CAST(0 AS BIT)
                        END AS IsDelivered,

                        CASE
                            WHEN MR.ReadOn IS NOT NULL
                                THEN CAST(1 AS BIT)
                            ELSE CAST(0 AS BIT)
                        END AS IsRead

                    FROM chat.MessageReceipts MR

                    WHERE
                        MR.MessageId = PM.MessageId

                    ORDER BY
                        MR.UserId

                    FOR JSON PATH
                ),
                '[]'
            ) AS ReceiptsJson,

            ------------------------------------------------------------------
            -- Pagination
            ------------------------------------------------------------------

            CASE
                WHEN EXISTS
                (
                    SELECT 1
                    FROM PageMessages MoreMessages
                    WHERE MoreMessages.RowNumber = @PageSize + 1
                )
                    THEN CAST(1 AS BIT)

                ELSE CAST(0 AS BIT)
            END AS HasMore

        FROM PageMessages PM

        ----------------------------------------------------------------------
        -- Reply Message
        ----------------------------------------------------------------------

        LEFT JOIN chat.Messages ReplyMessage
            ON ReplyMessage.MessageId = PM.ReplyToMessageId

        LEFT JOIN auth.Users ReplySender
            ON ReplySender.UserId = ReplyMessage.SenderUserId

        ----------------------------------------------------------------------
        -- Forwarded Message
        ----------------------------------------------------------------------

        LEFT JOIN chat.Messages ForwardedMessage
            ON ForwardedMessage.MessageId = PM.ForwardedFromMessageId

        LEFT JOIN auth.Users ForwardedSender
            ON ForwardedSender.UserId = ForwardedMessage.SenderUserId

        ----------------------------------------------------------------------
        -- Return only requested page
        ----------------------------------------------------------------------

        WHERE
            PM.RowNumber <= @PageSize

        ----------------------------------------------------------------------
        -- Chat UI receives chronological order
        ----------------------------------------------------------------------

        ORDER BY
            PM.MessageId ASC;

    END TRY

    BEGIN CATCH

        THROW;

    END CATCH
END;
GO