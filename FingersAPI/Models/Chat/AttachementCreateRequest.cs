namespace FingersAPI.Models.Chat
{
    public class AttachmentCreateRequest
    {
        public string PublicId { get; set; } = string.Empty;
        public string FileName { get; set; } = string.Empty;
        public string OriginalFileName { get; set; } = string.Empty;
        public string ContentType { get; set; } = string.Empty;
        public string FileExtension { get; set; } = string.Empty;
        public long FileSize { get; set; }
        public string StoragePath { get; set; } = string.Empty;
        public string? ThumbnailPath { get; set; } 
        public int? DurationInSeconds { get; set; }
        public int? Width { get; set; }
        public int? Height { get; set; }
    }
}