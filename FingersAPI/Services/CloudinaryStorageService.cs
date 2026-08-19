using CloudinaryDotNet;
using FingersAPI.Services.Interfaces;

namespace FingersAPI.Services
{
    public class CloudinaryStorageService : IFileStorageService
    {
        private readonly Cloudinary _cloudinary;

        public CloudinaryStorageService(Cloudinary cloudinary)
        {
            _cloudinary = cloudinary;
        }

        public string GenerateUploadSignature(IDictionary<string, object> parameters)
        {
            return _cloudinary.Api.SignParameters(parameters);
        }
    }
}
