CREATE PROCEDURE dbo.DatabaseConnectionTest
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        CAST(1 AS BIT) AS Success,
        'Database connection successful.' AS Message;
END;
GO