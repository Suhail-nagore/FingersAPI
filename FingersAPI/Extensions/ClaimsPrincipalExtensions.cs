using FingersAPI.Common.Constants;
using System.Security.Claims;

namespace FingersAPI.Extensions
{
    public static class ClaimsPrincipalExtensions
    {
        public static long GetUserId(this ClaimsPrincipal user)
        {
            string? userId = user.FindFirst(JwtClaimNames.UserId)?.Value;

            if (!long.TryParse(userId, out long result))
            {
                throw new UnauthorizedAccessException(
                    "Authenticated user does not contain a valid user identifier.");
            }

            return result;
        }

        public static string GetUserName(this ClaimsPrincipal user)
        {
            string? userName = user.FindFirst(JwtClaimNames.UserName)?.Value;

            if (string.IsNullOrWhiteSpace(userName))
            {
                throw new UnauthorizedAccessException(
                    "Authenticated user does not contain a valid username.");
            }

            return userName;
        }

        public static string GetDisplayName(this ClaimsPrincipal user)
        {
            string? displayName = user.FindFirst(JwtClaimNames.DisplayName)?.Value;

            if (string.IsNullOrWhiteSpace(displayName))
            {
                throw new UnauthorizedAccessException(
                    "Authenticated user does not contain a valid display name.");
            }

            return displayName;
        }
    }
}