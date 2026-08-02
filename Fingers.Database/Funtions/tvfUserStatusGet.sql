/*
==============================================================================
Project      : Fingers
Module       : Common
Object Type  : Function
Object Name  : tvfLookupIdGet
Author       : Mohd Suhail
Description  : Returns lookup identifier by status code.
==============================================================================
*/

CREATE OR ALTER FUNCTION common.tvfUserStatusGet
(
    @StatusCode NVARCHAR(50)
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        UserStatusId
    FROM common.UserStatuses
    WHERE StatusCode = @StatusCode
      AND IsActive = 1
);
GO