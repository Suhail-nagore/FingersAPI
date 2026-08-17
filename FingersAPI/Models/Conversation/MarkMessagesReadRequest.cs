namespace FingersAPI.Models.Conversation
{
    public class MarkMessagesReadRequest
    {
        public long ConversationId { get; set; }
        public long LastMessageReadId { get; set; }
    }
}
