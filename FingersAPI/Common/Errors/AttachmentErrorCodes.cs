namespace FingersAPI.Common.Errors
{
    public static class AttachmentErrorCodes
    {
        public const int InvalidUser = 50001;

        public const int PublicIdRequired = 50002;

        public const int FileNameRequired = 50003;

        public const int OriginalFileNameRequired = 50004;

        public const int ContentTypeRequired = 50005;

        public const int FileExtensionRequired = 50006;

        public const int FileSizeInvalid = 50007;

        public const int StoragePathRequired = 50008;

        public const int WidthInvalid = 50009;

        public const int HeightInvalid = 50010;

        public const int DurationInvalid = 50011;

        public const int PublicIdAlreadyExists = 50012;
    }
}