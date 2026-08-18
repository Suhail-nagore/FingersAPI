CREATE OR ALTER PROCEDURE chat.EditMessage
(
    @CurrentUserId BIGINT,
    @MessageId BIGINT,
    @Content NVARCHAR(MAX),
    @Success BIT OUTPUT,
    @Message NVARCHAR(500) OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @SentOn DATETIME2;
    DECLARE @Now DATETIME2 = SYSUTCDATETIME();

    BEGIN TRY

        ----------------------------------------------------------------------
        -- Normalize Content
        ----------------------------------------------------------------------

        SET @Content = NULLIF(LTRIM(RTRIM(@Content)), '');


        ----------------------------------------------------------------------
        -- Validate Content
        ----------------------------------------------------------------------

        IF @Content IS NULL
        BEGIN
            SET @Success = 0;
            SET @Message = 'Message content is required.';
            RETURN;
        END;


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
        -- Load Message
        ----------------------------------------------------------------------

        SELECT
            @SentOn = SentOn
        FROM chat.Messages
        WHERE MessageId = @MessageId
          AND SenderUserId = @CurrentUserId
          AND DeletedOn IS NULL;


        ----------------------------------------------------------------------
        -- Message Not Found / Not Owned / Deleted
        ----------------------------------------------------------------------

        IF @SentOn IS NULL
        BEGIN
            SET @Success = 0;
            SET @Message = 'Message not found or you are not allowed to edit it.';
            RETURN;
        END;


        ----------------------------------------------------------------------
        -- Validate 15 Minute Edit Window
        ----------------------------------------------------------------------

        IF @Now > DATEADD(MINUTE, 15, @SentOn)
        BEGIN
            SET @Success = 0;
            SET @Message = 'Message can only be edited within 15 minutes of sending.';
            RETURN;
        END;


        ----------------------------------------------------------------------
        -- Update Message
        ----------------------------------------------------------------------

        UPDATE chat.Messages
        SET
            Content = @Content,
            EditedOn = @Now,
            EditedByUserId = @CurrentUserId
        WHERE
            MessageId = @MessageId
            AND SenderUserId = @CurrentUserId
            AND DeletedOn IS NULL
            AND @Now <= DATEADD(MINUTE, 15, SentOn);


        ----------------------------------------------------------------------
        -- Make Sure Update Happened
        ----------------------------------------------------------------------

        IF @@ROWCOUNT = 0
        BEGIN
            SET @Success = 0;
            SET @Message = 'Message could not be edited.';
            RETURN;
        END;


        ----------------------------------------------------------------------
        -- Success
        ----------------------------------------------------------------------

        SET @Success = 1;
        SET @Message = 'Message edited successfully.';

    END TRY

    BEGIN CATCH

        SET @Success = 0;
        SET @Message = ERROR_MESSAGE();

    END CATCH
END;
GO