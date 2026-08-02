namespace FingersAPI.Models.User
{
    public class UserSearchResult
    {
        public long UserId { get; set; }
        public string UserName { get; set; } = string.Empty;
        public string DisplayName { get; set; } = string.Empty;
    }
}
