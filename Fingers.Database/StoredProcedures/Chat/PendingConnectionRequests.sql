/*
==============================================================================
Project      : Fingers
Module       : Chat
Object Type  : Stored Procedure
Object Name  : PendingConnectionRequests
Author       : Mohd Suhail
Description  : Returns pending connection requests for the logged-in user.
==============================================================================
*/

CREATE OR ALTER PROCEDURE chat.PendingConnectionRequests
(
    @ReceiverUserId BIGINT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @PendingStatusId TINYINT;

    --------------------------------------------------------------------------
    -- Pending Status
    --------------------------------------------------------------------------

    SELECT
        @PendingStatusId = ConnectionStatusId
    FROM common.tvfConnectionStatusGet('PENDING');

    --------------------------------------------------------------------------
    -- Pending Requests
    --------------------------------------------------------------------------

    SELECT
        UC.ConnectionId,
        U.UserId AS SenderUserId,
        U.UserName,
        U.DisplayName,
        UC.CreatedOn AS RequestedOn
    FROM chat.UserConnections UC

    INNER JOIN auth.Users U
        ON UC.SenderUserId = U.UserId

    WHERE
        UC.ReceiverUserId = @ReceiverUserId
        AND UC.ConnectionStatusId = @PendingStatusId
        AND U.IsActive = 1

    ORDER BY
        UC.CreatedOn DESC;
END;
GO