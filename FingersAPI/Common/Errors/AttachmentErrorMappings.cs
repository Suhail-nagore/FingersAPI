using Microsoft.AspNetCore.Http;

namespace FingersAPI.Common.Errors
{
    public static class AttachmentErrorMappings
    {
        public static bool TryGet(
            int errorCode,
            out int statusCode,
            out string message)
        {
            switch (errorCode)
            {
                case AttachmentErrorCodes.InvalidUser:
                    statusCode = StatusCodes.Status401Unauthorized;
                    message = "Invalid user.";
                    return true;

                case AttachmentErrorCodes.PublicIdRequired:
                    statusCode = StatusCodes.Status400BadRequest;
                    message = "PublicId is required.";
                    return true;

                case AttachmentErrorCodes.FileNameRequired:
                    statusCode = StatusCodes.Status400BadRequest;
                    message = "FileName is required.";
                    return true;

                case AttachmentErrorCodes.OriginalFileNameRequired:
                    statusCode = StatusCodes.Status400BadRequest;
                    message = "OriginalFileName is required.";
                    return true;

                case AttachmentErrorCodes.ContentTypeRequired:
                    statusCode = StatusCodes.Status400BadRequest;
                    message = "ContentType is required.";
                    return true;

                case AttachmentErrorCodes.FileExtensionRequired:
                    statusCode = StatusCodes.Status400BadRequest;
                    message = "FileExtension is required.";
                    return true;

                case AttachmentErrorCodes.FileSizeInvalid:
                    statusCode = StatusCodes.Status400BadRequest;
                    message = "FileSize must be greater than zero.";
                    return true;

                case AttachmentErrorCodes.StoragePathRequired:
                    statusCode = StatusCodes.Status400BadRequest;
                    message = "StoragePath is required.";
                    return true;

                case AttachmentErrorCodes.WidthInvalid:
                    statusCode = StatusCodes.Status400BadRequest;
                    message = "Width must be greater than zero.";
                    return true;

                case AttachmentErrorCodes.HeightInvalid:
                    statusCode = StatusCodes.Status400BadRequest;
                    message = "Height must be greater than zero.";
                    return true;

                case AttachmentErrorCodes.DurationInvalid:
                    statusCode = StatusCodes.Status400BadRequest;
                    message = "DurationInSeconds cannot be negative.";
                    return true;

                case AttachmentErrorCodes.PublicIdAlreadyExists:
                    statusCode = StatusCodes.Status409Conflict;
                    message = "Attachment with this PublicId already exists.";
                    return true;

                default:
                    statusCode = StatusCodes.Status500InternalServerError;
                    message = "An unexpected database error occurred.";
                    return false;
            }
        }
    }
}