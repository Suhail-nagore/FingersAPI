/*
==============================================================================
Project      : Fingers
Module       : User
Object Type  : Stored Procedure
Object Name  : UsersSearch
Author       : Mohd Suhail
Description  : Searches active users by username or display name.
==============================================================================
*/

create procedure auth.UsersSearch
(
	@Keyword nvarchar(max),
	@CurrentUserId bigint
)
as
begin
	set nocount on;

	declare @UserStatusId tinyint;

	select @UserStatusId = UserStatusId
	from common.UserStatuses
	where StatusCode = 'ACTIVE' and IsActive =1;

	select top (20) UserId, UserName, DisplayName
	from auth.Users
	where IsActive = 1 and UserStatusId = @UserStatusId and UserId <> @CurrentUserId and (UserName like '%' + @Keyword + '%' or DisplayName like '%' + @Keyword + '%')
	order by UserName;

end
go
