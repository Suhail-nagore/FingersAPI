CREATE OR ALTER FUNCTION common.tvfConnectionStatusGet
(
    @StatusCode NVARCHAR(50)
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        ConnectionStatusId
    FROM common.ConnectionStatuses
    WHERE StatusCode = @StatusCode
      AND IsActive = 1
);
GO