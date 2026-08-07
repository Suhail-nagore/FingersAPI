namespace FingersAPI.Models.Conversation
{
    public class SendMessageResult
    {
        public long ConversationId { get; set; }

        public long MessageId { get; set; }

        public long SenderUserId { get; set; }

        public Guid ClientMessageId { get; set; }

        public byte MessageTypeId { get; set; }

        public string? Content { get; set; }

        public long? ReplyToMessageId { get; set; }

        public long? ForwardedFromMessageId { get; set; }

        public DateTime SentOn { get; set; }
    }
}