namespace FingersAPI.Models.Chat
{
    public class MessagesGetRequest
    {
        public long ConversationId { get; set; }

        public long? BeforeMessageId { get; set; }

        public int PageSize { get; set; } = 50;
    }
}
