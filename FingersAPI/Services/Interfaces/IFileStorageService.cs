namespace FingersAPI.Services.Interfaces
{
    public interface IFileStorageService
    {
        string GenerateUploadSignature(IDictionary<string, object> parameters);
    }
}
