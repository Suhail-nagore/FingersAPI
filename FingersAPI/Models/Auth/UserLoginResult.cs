namespace FingersAPI.Models.Auth
{
    public class UserLoginResult
    {
        public long UserId { get; set; }
        public string UserName { get; set; } = string.Empty;
        public string DisplayName {  get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string PasswordHash {  get; set; } = string.Empty;
        public byte UserStatusId { get; set; }
    }
}
