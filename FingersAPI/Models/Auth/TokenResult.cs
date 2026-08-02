namespace FingersAPI.Models.Auth
{
    public class TokenResult
    {
        public string AccessToken { get; set; } = string.Empty;
        public DateTime AccessTokenExpiry { get; set; }
    }
}
