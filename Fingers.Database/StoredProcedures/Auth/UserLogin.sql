CREATE OR ALTER PROCEDURE auth.UserLogin
(
	@UserName nvarchar(50),	
	@Success bit output,
	@Message nvarchar(500) output
)
as
begin
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	begin try
		if not exists
		(
			select 1
			from auth.Users
			where UserName = @UserName
			and IsActive=1
		)
		
		begin
			set @Success = 0;
			set @Message = 'Invalid Username or password';

			return;
		end

		select UserId, UserName, DisplayName, Email, PasswordHash,UserStatusId
		from auth.Users
		where UserName = @UserName and IsActive = 1;

		set @Success = 1;
		set @Message = 'Login Successfull.';

	end try

	begin catch
		set @Success = 0;
		set @Message = error_message();
	end catch
end
go
