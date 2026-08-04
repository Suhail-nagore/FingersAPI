USE [ChatFingers]
GO
/****** Object:  StoredProcedure [chat].[SendConnectionRequest]    Script Date: 04-08-2026 10:01:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
==============================================================================
Project      : Fingers
Module       : Chat
Object Type  : Stored Procedure
Object Name  : SendConnectionRequest
Author       : Mohd Suhail
Description  : Sends a connection request to another user.
==============================================================================
*/

ALTER   PROCEDURE [chat].[SendConnectionRequest]
(
    @SenderUserId       BIGINT,
    @ReceiverUserId     BIGINT,

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

    DECLARE @ConnectionId BIGINT;
    DECLARE @CurrentStatusId TINYINT;

    BEGIN TRY

        BEGIN TRANSACTION;

        ----------------------------------------------------------------------
        -- Get Status Ids
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
        -- Cannot Send Request To Yourself
        ----------------------------------------------------------------------

        IF @SenderUserId = @ReceiverUserId
        BEGIN
            SET @Success = 0;
            SET @Message = 'You cannot send a connection request to yourself.';

            ROLLBACK TRANSACTION;
            RETURN;
        END;

        ----------------------------------------------------------------------
        -- Receiver Must Exist
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
            SET @Message = 'User not found.';

            ROLLBACK TRANSACTION;
            RETURN;
        END;

        ----------------------------------------------------------------------
        -- Existing Relationship
        ----------------------------------------------------------------------

        SELECT
            @ConnectionId = ConnectionId,
            @CurrentStatusId = ConnectionStatusId
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
        -- Existing Pending Request
        ----------------------------------------------------------------------

        IF @CurrentStatusId = @PendingStatusId
        BEGIN
            SET @Success = 0;
            SET @Message = 'Connection request is already pending.';

            ROLLBACK TRANSACTION;
            RETURN;
        END;

        ----------------------------------------------------------------------
        -- Already Connected
        ----------------------------------------------------------------------

        IF @CurrentStatusId = @AcceptedStatusId
        BEGIN
            SET @Success = 0;
            SET @Message = 'Users are already connected.';

            ROLLBACK TRANSACTION;
            RETURN;
        END;

        ----------------------------------------------------------------------
        -- Blocked
        ----------------------------------------------------------------------

        IF @CurrentStatusId = @BlockedStatusId
        BEGIN
            SET @Success = 0;
            SET @Message = 'Unable to send connection request.';

            ROLLBACK TRANSACTION;
            RETURN;
        END;

        ----------------------------------------------------------------------
        -- Rejected -> Send Again
        ----------------------------------------------------------------------

        IF @CurrentStatusId = @RejectedStatusId
        BEGIN
            UPDATE chat.UserConnections
            SET
                ConnectionStatusId = @PendingStatusId,
                ModifiedOn = SYSUTCDATETIME(),
                ModifiedByUserId = @SenderUserId
            WHERE ConnectionId = @ConnectionId;

            COMMIT TRANSACTION;

            SET @Success = 1;
            SET @Message = 'Connection request sent successfully.';

            RETURN;
        END;

        ----------------------------------------------------------------------
        -- First Request
        ----------------------------------------------------------------------

        INSERT INTO chat.UserConnections
        (
            SenderUserId,
            ReceiverUserId,
            ConnectionStatusId,
            CreatedByUserId
        )
        VALUES
        (
            @SenderUserId,
            @ReceiverUserId,
            @PendingStatusId,
            @SenderUserId
        );

        COMMIT TRANSACTION;

        SET @Success = 1;
        SET @Message = 'Connection request sent successfully.';

    END TRY

    BEGIN CATCH

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @Success = 0;
        SET @Message = ERROR_MESSAGE();

    END CATCH

END
