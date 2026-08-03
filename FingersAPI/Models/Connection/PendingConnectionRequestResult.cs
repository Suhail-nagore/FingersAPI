namespace FingersAPI.Models.Connection
{
    public class PendingConnectionRequestResult
    {
        public long ConnectionId { get; set; }
        public long SenderUserId { get; set; }
        public string UserName { get; set; } = string.Empty;
        public string DisplayName {  get; set; } = string.Empty;
        public DateTime RequestedOn { get; set; }
    }
}
