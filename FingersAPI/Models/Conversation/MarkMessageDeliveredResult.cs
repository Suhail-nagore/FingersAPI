namespace FingersAPI.Models.Conversation
{
    public class MarkMessageDeliveredResult
    {
        public long MessageId { get; set; }
        public long UserId { get; set; }
        public DateTime? DeliveredOn { get; set; }
        public DateTime? ReadOn { get; set; }
    }
}
