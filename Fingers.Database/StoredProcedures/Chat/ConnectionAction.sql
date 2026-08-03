/*
==============================================================================
Project      : Fingers
Module       : Chat
Object Type  : Stored Procedure
Object Name  : ConnectionAction
Author       : Mohd Suhail
Description  : Performs action on a pending connection request.
==============================================================================
*/

CREATE OR ALTER PROCEDURE chat.ConnectionAction
(
    @ConnectionId       BIGINT,
    @CurrentUserId      BIGINT,
    @Action             NVARCHAR(20),

    @Success            BIT OUTPUT,
    @Message            NVARCHAR(500) OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @PendingStatusId TINYINT;
    DECLARE @AcceptedStatusId TINYINT;
    DECLARE @RejectedStatusId TINYINT;
    DECLARE @BlockedStatusId TINYINT;

    DECLARE @CurrentStatusId TINYINT;
    DECLARE @ReceiverUserId BIGINT;

    BEGIN TRY

        BEGIN TRANSACTION;

        ----------------------------------------------------------------------
        -- Normalize Action
        ----------------------------------------------------------------------

        SET @Action = UPPER(LTRIM(RTRIM(@Action)));

        ----------------------------------------------------------------------
        -- Status Ids
        ----------------------------------------------------------------------

        SELECT @PendingStatusId = ConnectionStatusId
        FROM common.tvfConnectionStatusGet('PENDING');

        SELECT @AcceptedStatusId = ConnectionStatusId
        FROM common.tvfConnectionStatusGet('ACCEPTED');

        SELECT @RejectedStatusId = ConnectionStatusId
        FROM common.tvfConnectionStatusGet('REJECTED');

        SELECT @BlockedStatusId = ConnectionStatusId
        FROM common.tvfConnectionStatusGet('BLOCKED');

        ----------------------------------------------------------------------
        -- Load Connection
        ----------------------------------------------------------------------

        SELECT
            @ReceiverUserId = ReceiverUserId,
            @CurrentStatusId = ConnectionStatusId
        FROM chat.UserConnections
        WHERE ConnectionId = @ConnectionId;

        ----------------------------------------------------------------------
        -- Connection Exists
        ----------------------------------------------------------------------

        IF @CurrentStatusId IS NULL
        BEGIN
            SET @Success = 0;
            SET @Message = 'Connection request not found.';

            ROLLBACK TRANSACTION;
            RETURN;
        END;

        ----------------------------------------------------------------------
        -- Only Receiver Can Perform Action
        ----------------------------------------------------------------------

        IF @ReceiverUserId <> @CurrentUserId
        BEGIN
            SET @Success = 0;
            SET @Message = 'You are not authorized to perform this action.';

            ROLLBACK TRANSACTION;
            RETURN;
        END;

        ----------------------------------------------------------------------
        -- ACCEPT
        ----------------------------------------------------------------------

        IF @Action = 'ACCEPT'
        BEGIN
            IF @CurrentStatusId <> @PendingStatusId
            BEGIN
                SET @Success = 0;
                SET @Message = 'Only pending requests can be accepted.';

                ROLLBACK TRANSACTION;
                RETURN;
            END;

            UPDATE chat.UserConnections
            SET
                ConnectionStatusId = @AcceptedStatusId,
                ModifiedOn = SYSUTCDATETIME(),
                ModifiedByUserId = @CurrentUserId
            WHERE ConnectionId = @ConnectionId;

            COMMIT TRANSACTION;

            SET @Success = 1;
            SET @Message = 'Connection request accepted successfully.';

            RETURN;
        END;

        ----------------------------------------------------------------------
        -- REJECT
        ----------------------------------------------------------------------

        IF @Action = 'REJECT'
        BEGIN
            IF @CurrentStatusId <> @PendingStatusId
            BEGIN
                SET @Success = 0;
                SET @Message = 'Only pending requests can be rejected.';

                ROLLBACK TRANSACTION;
                RETURN;
            END;

            UPDATE chat.UserConnections
            SET
                ConnectionStatusId = @RejectedStatusId,
                ModifiedOn = SYSUTCDATETIME(),
                ModifiedByUserId = @CurrentUserId
            WHERE ConnectionId = @ConnectionId;

            COMMIT TRANSACTION;

            SET @Success = 1;
            SET @Message = 'Connection request rejected successfully.';

            RETURN;
        END;

        ----------------------------------------------------------------------
        -- BLOCK
        ----------------------------------------------------------------------

        IF @Action = 'BLOCK'
        BEGIN
            IF @CurrentStatusId = @BlockedStatusId
            BEGIN
                SET @Success = 0;
                SET @Message = 'User is already blocked.';

                ROLLBACK TRANSACTION;
                RETURN;
            END;

            UPDATE chat.UserConnections
            SET
                ConnectionStatusId = @BlockedStatusId,
                BlockedByUserId = @CurrentUserId,
                ModifiedOn = SYSUTCDATETIME(),
                ModifiedByUserId = @CurrentUserId
            WHERE ConnectionId = @ConnectionId;

            COMMIT TRANSACTION;

            SET @Success = 1;
            SET @Message = 'User blocked successfully.';

            RETURN;
        END;

        ----------------------------------------------------------------------
        -- Invalid Action
        ----------------------------------------------------------------------

        SET @Success = 0;
        SET @Message = 'Invalid connection action.';

        ROLLBACK TRANSACTION;

    END TRY

    BEGIN CATCH

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @Success = 0;
        SET @Message = ERROR_MESSAGE();

    END CATCH
END
GO