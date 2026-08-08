CREATE OR ALTER PROCEDURE chat.ConversationsGet
(
    @CurrentUserId BIGINT,
    @SearchText NVARCHAR(100) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY

        ----------------------------------------------------------------------
        -- Variables
        ----------------------------------------------------------------------

        DECLARE @PrivateConversationTypeId TINYINT;

        ----------------------------------------------------------------------
        -- Normalize Search
        ----------------------------------------------------------------------

        SET @SearchText = NULLIF(LTRIM(RTRIM(@SearchText)), '');

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
        -- Get Private Conversation Type
        ----------------------------------------------------------------------

        SELECT
            @PrivateConversationTypeId = ConversationTypeId
        FROM common.tvfConversationTypeGet('PRIVATE');

        ----------------------------------------------------------------------
        -- Get Conversations
        ----------------------------------------------------------------------

        SELECT

            ------------------------------------------------------------------
            -- Conversation
            ------------------------------------------------------------------

            C.ConversationId,

            C.ConversationTypeId,

            ------------------------------------------------------------------
            -- Conversation Title
            --
            -- PRIVATE:
            --     Other user's DisplayName
            --
            -- GROUP:
            --     Conversation Title
            ------------------------------------------------------------------

            CASE
                WHEN C.ConversationTypeId = @PrivateConversationTypeId
                    THEN OtherUser.DisplayName

                ELSE C.Title
            END AS Title,

            ------------------------------------------------------------------
            -- Conversation Image
            --
            -- PRIVATE:
            --     Other user's profile picture
            --
            -- GROUP:
            --     Conversation image
            ------------------------------------------------------------------

            CASE
                WHEN C.ConversationTypeId = @PrivateConversationTypeId
                    THEN OtherUser.ProfilePictureUrl

                ELSE C.ConversationImageUrl
            END AS ConversationImageUrl,

            ------------------------------------------------------------------
            -- Other User
            --
            -- Only populated for private conversations
            ------------------------------------------------------------------

            CASE
                WHEN C.ConversationTypeId = @PrivateConversationTypeId
                    THEN OtherUser.UserId

                ELSE NULL
            END AS OtherUserId,

            CASE
                WHEN C.ConversationTypeId = @PrivateConversationTypeId
                    THEN OtherUser.UserName

                ELSE NULL
            END AS OtherUserName,

            CASE
                WHEN C.ConversationTypeId = @PrivateConversationTypeId
                    THEN OtherUser.LastSeenOn

                ELSE NULL
            END AS LastSeenOn,

            ------------------------------------------------------------------
            -- Last Message
            ------------------------------------------------------------------

            LastMessage.MessageId AS LastMessageId,

            CASE
                WHEN LastMessage.DeletedOn IS NULL
                    THEN LastMessage.Content

                ELSE NULL
            END AS LastMessage,

            LastMessage.MessageTypeId AS LastMessageTypeId,

            LastMessage.SenderUserId AS LastMessageSenderUserId,

            LastMessage.SentOn AS LastMessageOn,

            ------------------------------------------------------------------
            -- Deleted Last Message
            ------------------------------------------------------------------

            CASE
                WHEN LastMessage.DeletedOn IS NOT NULL
                    THEN CAST(1 AS BIT)

                ELSE CAST(0 AS BIT)
            END AS IsLastMessageDeleted,

            ------------------------------------------------------------------
            -- Unread Count
            ------------------------------------------------------------------

            ISNULL(Unread.UnreadCount, 0) AS UnreadCount,

            ------------------------------------------------------------------
            -- Participant Preferences
            ------------------------------------------------------------------

            CASE
                WHEN CP.PinnedOn IS NOT NULL
                    THEN CAST(1 AS BIT)

                ELSE CAST(0 AS BIT)
            END AS IsPinned,

            CP.IsMuted,

            CP.IsArchived,

            ------------------------------------------------------------------
            -- Hidden
            ------------------------------------------------------------------

            CASE
                WHEN CP.HiddenOn IS NOT NULL
                    THEN CAST(1 AS BIT)

                ELSE CAST(0 AS BIT)
            END AS IsHidden

        FROM chat.ConversationParticipants CP

        INNER JOIN chat.Conversations C
            ON C.ConversationId = CP.ConversationId

        ----------------------------------------------------------------------
        -- Find Other Participant
        --
        -- For private conversations only.
        ----------------------------------------------------------------------

        OUTER APPLY
        (
            SELECT TOP (1)

                U.UserId,

                U.UserName,

                U.DisplayName,

                U.ProfilePictureUrl,

                U.LastSeenOn

            FROM chat.ConversationParticipants OtherCP

            INNER JOIN auth.Users U
                ON U.UserId = OtherCP.UserId

            WHERE
                OtherCP.ConversationId = C.ConversationId

                AND OtherCP.UserId <> @CurrentUserId

                AND OtherCP.LeftOn IS NULL

                AND U.IsActive = 1

        ) OtherUser

        ----------------------------------------------------------------------
        -- Get Latest Message
        ----------------------------------------------------------------------

        OUTER APPLY
        (
            SELECT TOP (1)

                M.MessageId,

                M.Content,

                M.MessageTypeId,

                M.SenderUserId,

                M.SentOn,

                M.DeletedOn

            FROM chat.Messages M

            WHERE
                M.ConversationId = C.ConversationId

            ORDER BY
                M.SentOn DESC,
                M.MessageId DESC

        ) LastMessage

        ----------------------------------------------------------------------
        -- Calculate Unread Messages
        --
        -- Only messages:
        --   1. Belong to this conversation
        --   2. Have a receipt for the current user
        --   3. Are not read
        --   4. Were not sent by the current user
        ----------------------------------------------------------------------

        OUTER APPLY
        (
            SELECT
                COUNT_BIG(*) AS UnreadCount

            FROM chat.MessageReceipts MR

            INNER JOIN chat.Messages M
                ON M.MessageId = MR.MessageId

            WHERE
                MR.UserId = @CurrentUserId

                AND MR.ReadOn IS NULL

                AND M.ConversationId = C.ConversationId

                AND M.SenderUserId <> @CurrentUserId

        ) Unread

        ----------------------------------------------------------------------
        -- Current User Must Be An Active Participant
        ----------------------------------------------------------------------

        WHERE
            CP.UserId = @CurrentUserId

            AND CP.LeftOn IS NULL

        ----------------------------------------------------------------------
        -- Hidden Conversations
        --
        -- Hidden means the user intentionally hid the conversation.
        ----------------------------------------------------------------------

            AND CP.HiddenOn IS NULL

        ----------------------------------------------------------------------
        -- Archived Conversations
        --
        -- This endpoint represents the normal inbox.
        -- Archived conversations will be handled separately.
        ----------------------------------------------------------------------

            AND CP.IsArchived = 0

        ----------------------------------------------------------------------
        -- Search
        ----------------------------------------------------------------------

            AND
            (
                @SearchText IS NULL

                OR

                (
                    C.ConversationTypeId = @PrivateConversationTypeId

                    AND
                    (
                        OtherUser.DisplayName LIKE '%' + @SearchText + '%'

                        OR

                        OtherUser.UserName LIKE '%' + @SearchText + '%'
                    )
                )

                OR

                (
                    C.ConversationTypeId <> @PrivateConversationTypeId

                    AND C.Title LIKE '%' + @SearchText + '%'
                )
            )

        ----------------------------------------------------------------------
        -- Ordering
        --
        -- 1. Pinned conversations first
        -- 2. Most recent message
        -- 3. ConversationId as stable tie-breaker
        ----------------------------------------------------------------------

        ORDER BY

            CASE
                WHEN CP.PinnedOn IS NOT NULL
                    THEN 1

                ELSE 0
            END DESC,

            LastMessage.SentOn DESC,

            C.ConversationId DESC;

    END TRY

    BEGIN CATCH

        THROW;

    END CATCH
END;
GO