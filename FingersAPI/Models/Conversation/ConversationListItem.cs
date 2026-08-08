namespace FingersAPI.Models.Conversation
{
    public class ConversationListItem
    {
        public long ConversationId { get; set; }
        public byte ConversationTypeId { get; set; }
        public string? Title { get; set; }
        public string? ConversationImageUrl { get; set; }
        public long? OtherUserId { get; set; }
        public string? OtherUserName { get; set; }
        public DateTime? LastSeenOn { get; set; }
        public long? LastMessageId { get; set; }
        public string? LastMessage { get; set; }
        public byte? LastMessageTypeId { get; set; }
        public long? LastMessageSenderUserId { get; set; }
        public DateTime? LastMessageOn { get; set; }
        public bool IsLastMessageDeleted { get; set; }
        public long UnreadCount { get; set; }
        public bool IsPinned    { get; set; }
        public bool IsMuted { get; set; }
        public bool IsArchived { get; set; }
        public bool IsHidden { get; set; }
    }
}
