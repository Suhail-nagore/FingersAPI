USE master;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.databases
    WHERE [name] = 'ChatFingers'
)
BEGIN
    CREATE DATABASE ChatFingers;
END
GO