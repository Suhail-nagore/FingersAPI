namespace FingersAPI.Models.Conversation
{
    public class EditMessageRequest
    {
        public long MessageId { get; set; }
        public string Content { get; set; } = string.Empty;
    }
}
