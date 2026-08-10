using System.Text.Json;
using System.Text.Json.Serialization;

namespace FingersAPI.Models.Chat
{
    public class MessageListItem
    {
        public long MessageId { get; set; }

        public long ConversationId { get; set; }

        public long SenderUserId { get; set; }

        public string? SenderUserName { get; set; }

        public string? SenderDisplayName { get; set; }

        public string? SenderProfilePictureUrl { get; set; }

        public byte MessageTypeId { get; set; }

        public string? Content { get; set; }

        // ------------------------------------------------------------
        // Reply
        // ------------------------------------------------------------

        public long? ReplyToMessageId { get; set; }

        public string? ReplyToContent { get; set; }

        public long? ReplyToSenderUserId { get; set; }

        public string? ReplyToSenderDisplayName { get; set; }

        public byte? ReplyToMessageTypeId { get; set; }

        // ------------------------------------------------------------
        // Forward
        // ------------------------------------------------------------

        public long? ForwardedFromMessageId { get; set; }

        public string? ForwardedContent { get; set; }

        public long? ForwardedSenderUserId { get; set; }

        public string? ForwardedSenderDisplayName { get; set; }

        public byte? ForwardedMessageTypeId { get; set; }

        // ------------------------------------------------------------
        // Edit
        // ------------------------------------------------------------

        public DateTime? EditedOn { get; set; }

        public long? EditedByUserId { get; set; }

        public bool IsEdited { get; set; }

        // ------------------------------------------------------------
        // Delete
        // ------------------------------------------------------------

        public DateTime? DeletedOn { get; set; }

        public long? DeletedByUserId { get; set; }

        public bool IsDeleted { get; set; }

        // ------------------------------------------------------------
        // Sent
        // ------------------------------------------------------------

        public DateTime SentOn { get; set; }

        // ------------------------------------------------------------
        // JSON returned by SQL
        // ------------------------------------------------------------

        [JsonIgnore]
        public string AttachmentsJson { get; set; } = "[]";
        [JsonIgnore]
        public string ReceiptsJson { get; set; } = "[]";

        // ------------------------------------------------------------
        // API objects
        // ------------------------------------------------------------

        public List<MessageAttachmentItem> Attachments { get; set; } = new();

        public List<MessageReceiptItem> Receipts { get; set; } = new();

        // ------------------------------------------------------------
        // Pagination
        // ------------------------------------------------------------

        public bool HasMore { get; set; }
    }

    public class MessageAttachmentItem
    {
        public long AttachmentId { get; set; }

        public string? FileName { get; set; }

        public string? OriginalFileName { get; set; }

        public string? ContentType { get; set; }

        public string? FileExtension { get; set; }

        public long FileSize { get; set; }

        public string? StoragePath { get; set; }

        public string? ThumbnailPath { get; set; }

        public int? DurationInSeconds { get; set; }

        public int? Width { get; set; }

        public int? Height { get; set; }

        public DateTime UploadedOn { get; set; }

        public long UploadedByUserId { get; set; }
    }

    public class MessageReceiptItem
    {
        public long MessageReceiptId { get; set; }

        public long UserId { get; set; }

        public DateTime? DeliveredOn { get; set; }

        public DateTime? ReadOn { get; set; }

        public bool IsDelivered { get; set; }

        public bool IsRead { get; set; }
    }
}