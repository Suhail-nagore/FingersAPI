using FingersAPI.Models.Auth;

namespace FingersAPI.Services.Interfaces
{
    public interface ITokenService
    {
        TokenResult GenerateToken(long UserId, string UserName, string DisplayName);
    }
}
