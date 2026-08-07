namespace FingersAPI.Models.Conversation
{
    public class SendMessageRequest
    {
        public long ReceiverUserId { get; set; }

        public Guid ClientMessageId { get; set; }

        public byte MessageTypeId { get; set; }

        public string? Content { get; set; }

        public long? ReplyToMessageId { get; set; }

        public long? ForwardedFromMessageId { get; set; }

        public List<MessageAttachmentRequest> Attachments { get; set; } = [];
    }
}