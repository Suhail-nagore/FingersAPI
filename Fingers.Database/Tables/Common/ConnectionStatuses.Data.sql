IF NOT EXISTS
(
    SELECT 1
    FROM common.ConnectionStatuses
    WHERE ConnectionStatusId = 1
)
BEGIN

    INSERT INTO common.ConnectionStatuses
    (
        ConnectionStatusId,
        StatusCode,
        StatusName,
        Description,
        DisplayOrder,
        IsActive
    )
    VALUES
    (1,'PENDING','Pending','Connection request is pending.',1,1),

    (2,'ACCEPTED','Accepted','Connection request accepted.',2,1),

    (3,'REJECTED','Rejected','Connection request rejected.',3,1),

    (4,'BLOCKED','Blocked','User has blocked the connection.',4,1);

END;
GO