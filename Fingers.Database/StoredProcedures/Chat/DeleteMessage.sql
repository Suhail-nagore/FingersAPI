CREATE OR ALTER PROCEDURE chat.DeleteMessage
(
    @CurrentUserId BIGINT,
    @MessageId BIGINT,
    @Success BIT OUTPUT,
    @Message NVARCHAR(500) OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @DeletedOn DATETIME2 = SYSUTCDATETIME();

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
        -- Validate Message
        ----------------------------------------------------------------------

        IF NOT EXISTS
        (
            SELECT 1
            FROM chat.Messages
            WHERE MessageId = @MessageId
        )
        BEGIN
            SET @Success = 0;
            SET @Message = 'Message not found.';
            RETURN;
        END;


        ----------------------------------------------------------------------
        -- Validate Ownership
        ----------------------------------------------------------------------

        IF NOT EXISTS
        (
            SELECT 1
            FROM chat.Messages
            WHERE MessageId = @MessageId
              AND SenderUserId = @CurrentUserId
        )
        BEGIN
            SET @Success = 0;
            SET @Message = 'You are not allowed to delete this message.';
            RETURN;
        END;


        ----------------------------------------------------------------------
        -- Already Deleted
        ----------------------------------------------------------------------

        IF EXISTS
        (
            SELECT 1
            FROM chat.Messages
            WHERE MessageId = @MessageId
              AND DeletedOn IS NOT NULL
        )
        BEGIN
            SET @Success = 1;
            SET @Message = 'Message already deleted.';
            RETURN;
        END;


        ----------------------------------------------------------------------
        -- Soft Delete Message
        ----------------------------------------------------------------------

        UPDATE chat.Messages
        SET
            DeletedOn = @DeletedOn,
            DeletedByUserId = @CurrentUserId
        WHERE
            MessageId = @MessageId
            AND SenderUserId = @CurrentUserId
            AND DeletedOn IS NULL;


        ----------------------------------------------------------------------
        -- Verify Update
        ----------------------------------------------------------------------

        IF @@ROWCOUNT = 0
        BEGIN
            SET @Success = 0;
            SET @Message = 'Message could not be deleted.';
            RETURN;
        END;


        ----------------------------------------------------------------------
        -- Success
        ----------------------------------------------------------------------

        SET @Success = 1;
        SET @Message = 'Message deleted successfully.';

    END TRY

    BEGIN CATCH

        SET @Success = 0;
        SET @Message = ERROR_MESSAGE();

    END CATCH
END;
GO