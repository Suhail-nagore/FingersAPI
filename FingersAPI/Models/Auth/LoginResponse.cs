using FingersAPI.Models.Common;

namespace FingersAPI.Models.Auth
{
    public class LoginResponse : ApiResponse
    {
        public long UserId { get; set; }
        public string UserName { get; set; } = string.Empty;
        public string DisplayName { get; set; }= string.Empty;
        public string? AccessToken { get; set; }
        public DateTime? AccessTokenExpiry { get; set; }
    }
}
