namespace FingersAPI.Models.Connection
{
    public class ConnectionListResult
    {
        public long ConnectionId { get; set; }

        public long UserId { get; set; }

        public string UserName { get; set; } = string.Empty;

        public string DisplayName { get; set; } = string.Empty;

        public DateTime? ActivityOn { get; set; }
    }
}