/*
==============================================================================
Project      : Fingers
Module       : Common
Object Type  : Seed Data
Object Name  : UserStatuses
Author       : Mohd Suhail
Description  : Inserts default user statuses.
==============================================================================
*/

IF NOT EXISTS (SELECT 1 FROM common.UserStatuses WHERE UserStatusId = 1)
BEGIN
    INSERT INTO common.UserStatuses
    (
        UserStatusId,
        StatusCode,
        StatusName,
        Description,
        DisplayOrder,
        IsActive
    )
    VALUES
    (1,'ACTIVE','Active','User account is active',1,1),
    (2,'SUSPENDED','Suspended','User account is suspended',2,1),
    (3,'LOCKED','Locked','User account is locked',3,1),
    (4,'DEACTIVATED','Deactivated','User account is deactivated',4,1),
    (5,'DELETED','Deleted','User account is soft deleted',5,1);
END
GO