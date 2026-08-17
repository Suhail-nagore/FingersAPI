CREATE OR ALTER PROCEDURE chat.MarkMessageDelivered
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
        -- Validate Receipt
        --
        -- The current user must have a receipt for this message.
        -- This prevents a user from marking another user's receipt.
        ----------------------------------------------------------------------

        IF NOT EXISTS
        (
            SELECT 1
            FROM chat.MessageReceipts
            WHERE MessageId = @MessageId
              AND UserId = @CurrentUserId
        )
        BEGIN
            SET @Success = 0;
            SET @Message = 'Message receipt not found.';
            RETURN;
        END;


        ----------------------------------------------------------------------
        -- Mark Delivered
        --
        -- Never overwrite an existing DeliveredOn value.
        ----------------------------------------------------------------------

        UPDATE chat.MessageReceipts
        SET
            DeliveredOn = COALESCE(
                DeliveredOn,
                SYSUTCDATETIME()
            )
        WHERE
            MessageId = @MessageId
            AND UserId = @CurrentUserId;


        ----------------------------------------------------------------------
        -- Success
        ----------------------------------------------------------------------

        SET @Success = 1;
        SET @Message = 'Message marked as delivered.';


        ----------------------------------------------------------------------
        -- Return Useful Data
        ----------------------------------------------------------------------

        SELECT
            MessageId,
            UserId,
            DeliveredOn,
            ReadOn
        FROM chat.MessageReceipts
        WHERE
            MessageId = @MessageId
            AND UserId = @CurrentUserId;

    END TRY

    BEGIN CATCH

        SET @Success = 0;
        SET @Message = ERROR_MESSAGE();

    END CATCH
END;
GO