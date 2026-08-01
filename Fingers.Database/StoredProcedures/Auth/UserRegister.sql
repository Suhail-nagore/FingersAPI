/*
==============================================================================
Project      : Fingers
Module       : Authentication
Object Type  : Stored Procedure
Object Name  : UserRegister
Author       : Mohd Suhail
Description  : Registers a new user.
==============================================================================
*/

CREATE OR ALTER PROCEDURE auth.UserRegister
(
    @Username       NVARCHAR(50),
    @DisplayName    NVARCHAR(100),
    @Email          NVARCHAR(320),
    @PasswordHash   NVARCHAR(MAX),

    @Success        BIT OUTPUT,
    @Message        NVARCHAR(500) OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @UserStatusId TINYINT;

    BEGIN TRY

        BEGIN TRANSACTION;

        -- Get Active User Status
        SELECT
            @UserStatusId = UserStatusId
        FROM common.UserStatuses
        WHERE StatusCode = 'ACTIVE'
          AND IsActive = 1;

        -- Validate Username
        IF EXISTS
        (
            SELECT 1
            FROM auth.Users
            WHERE Username = @Username
              AND IsActive = 1
        )
        BEGIN
            SET @Success = 0;
            SET @Message = 'Username already exists.';

            ROLLBACK TRANSACTION;
            RETURN;
        END;

        -- Validate Email
        IF EXISTS
        (
            SELECT 1
            FROM auth.Users
            WHERE Email = @Email
              AND IsActive = 1
        )
        BEGIN
            SET @Success = 0;
            SET @Message = 'Email already exists.';

            ROLLBACK TRANSACTION;
            RETURN;
        END;

        -- Insert User
        INSERT INTO auth.Users
        (
            Username,
            DisplayName,
            Email,
            PasswordHash,
            UserStatusId
        )
        VALUES
        (
            @Username,
            @DisplayName,
            @Email,
            @PasswordHash,
            @UserStatusId
        );

        COMMIT TRANSACTION;

        SET @Success = 1;
        SET @Message = 'User registered successfully.';

    END TRY

    BEGIN CATCH

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @Success = 0;
        SET @Message = ERROR_MESSAGE();

    END CATCH
END
GO