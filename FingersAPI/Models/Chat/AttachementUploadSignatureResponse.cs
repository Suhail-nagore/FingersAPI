namespace FingersAPI.Models.Chat
{
    public class AttachementUploadSignatureResponse
    {
        public string Signature { get; set; } = string.Empty;
        public long TimeStamp { get; set; }
        public string CloudName { get; set; } = string.Empty;
        public string ApiKey { get; set; } = string.Empty;
        public string ResourceType {  get; set; } = string.Empty;
        public string Folder { get; set; } = string.Empty;

    }
}
