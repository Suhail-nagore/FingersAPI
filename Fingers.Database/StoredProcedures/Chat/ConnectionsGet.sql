/*
==============================================================================
Project      : Fingers
Module       : Chat
Object Type  : Stored Procedure
Object Name  : ConnectionsGet
Author       : Mohd Suhail
Description  : Returns connection list based on requested list type.
==============================================================================
*/

CREATE OR ALTER PROCEDURE chat.ConnectionsGet
(
    @UserId BIGINT,
    @ListType NVARCHAR(30),
    @SearchText NVARCHAR(100) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    --------------------------------------------------------------------------
    -- Normalize Input
    --------------------------------------------------------------------------

    SET @ListType = UPPER(LTRIM(RTRIM(@ListType)));
    SET @SearchText = NULLIF(LTRIM(RTRIM(@SearchText)), '');

    --------------------------------------------------------------------------
    -- Status Ids
    --------------------------------------------------------------------------

    DECLARE @PendingStatusId TINYINT;
    DECLARE @AcceptedStatusId TINYINT;
    DECLARE @BlockedStatusId TINYINT;

    SELECT @PendingStatusId = ConnectionStatusId
    FROM common.tvfConnectionStatusGet('PENDING');

    SELECT @AcceptedStatusId = ConnectionStatusId
    FROM common.tvfConnectionStatusGet('ACCEPTED');

    SELECT @BlockedStatusId = ConnectionStatusId
    FROM common.tvfConnectionStatusGet('BLOCKED');

    --------------------------------------------------------------------------
    -- My Connections
    --------------------------------------------------------------------------

    IF @ListType = 'MYCONNECTIONS'
    BEGIN

        SELECT
            UC.ConnectionId,
            U.UserId,
            U.UserName,
            U.DisplayName,
            UC.ConnectedOn AS ActivityOn
        FROM chat.UserConnections UC

        INNER JOIN auth.Users U
            ON U.UserId =
            CASE
                WHEN UC.SenderUserId = @UserId
                    THEN UC.ReceiverUserId
                ELSE UC.SenderUserId
            END

        WHERE
        (
            UC.SenderUserId = @UserId
            OR
            UC.ReceiverUserId = @UserId
        )
        AND UC.ConnectionStatusId = @AcceptedStatusId
        AND U.IsActive = 1
        AND
        (
            @SearchText IS NULL
            OR U.DisplayName LIKE '%' + @SearchText + '%'
            OR U.UserName LIKE '%' + @SearchText + '%'
        )

        ORDER BY
            U.DisplayName;

        RETURN;
    END

    --------------------------------------------------------------------------
    -- Pending Requests
    --------------------------------------------------------------------------

    IF @ListType = 'PENDINGREQUESTS'
    BEGIN

        SELECT
            UC.ConnectionId,
            U.UserId,
            U.UserName,
            U.DisplayName,
            UC.CreatedOn AS ActivityOn
        FROM chat.UserConnections UC

        INNER JOIN auth.Users U
            ON U.UserId = UC.SenderUserId

        WHERE
            UC.ReceiverUserId = @UserId
            AND UC.ConnectionStatusId = @PendingStatusId
            AND U.IsActive = 1
            AND
            (
                @SearchText IS NULL
                OR U.DisplayName LIKE '%' + @SearchText + '%'
                OR U.UserName LIKE '%' + @SearchText + '%'
            )

        ORDER BY
            UC.CreatedOn DESC;

        RETURN;
    END

    --------------------------------------------------------------------------
    -- Blocked Users
    --------------------------------------------------------------------------

    IF @ListType = 'BLOCKEDUSERS'
    BEGIN

        SELECT
            UC.ConnectionId,
            U.UserId,
            U.UserName,
            U.DisplayName,
            UC.BlockedOn AS ActivityOn
        FROM chat.UserConnections UC

        INNER JOIN auth.Users U
            ON U.UserId =
            CASE
                WHEN UC.SenderUserId = @UserId
                    THEN UC.ReceiverUserId
                ELSE UC.SenderUserId
            END

        WHERE
            UC.BlockedByUserId = @UserId
            AND UC.ConnectionStatusId = @BlockedStatusId
            AND U.IsActive = 1
            AND
            (
                @SearchText IS NULL
                OR U.DisplayName LIKE '%' + @SearchText + '%'
                OR U.UserName LIKE '%' + @SearchText + '%'
            )

        ORDER BY
            UC.BlockedOn DESC;

        RETURN;
    END

    --------------------------------------------------------------------------
    -- Invalid List Type
    --------------------------------------------------------------------------

    THROW 50001, 'Invalid connection list type.', 1;

END
GO