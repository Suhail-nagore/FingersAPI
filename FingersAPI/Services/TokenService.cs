using FingersAPI.Common.Constants;
using FingersAPI.Models.Auth;
using FingersAPI.Services.Interfaces;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

namespace FingersAPI.Services
{
    public class TokenService: ITokenService
    {
        private readonly IConfiguration _configuration;

        public TokenService(IConfiguration configuration)
        {
            _configuration = configuration;
        }

        public TokenResult GenerateToken(long UserId, string UserName, string DisplayName)
        {
            string jwtKey = _configuration["jwt:Key"]!;
            string issuer = _configuration["jwt:Issuer"]!;
            string audience = _configuration["jwt:Audience"]!;
            int expiryMinutes = int.Parse(_configuration["jwt:ExpiryInMinutes"]!);

            var securityKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey));
            var credentials = new SigningCredentials(securityKey, SecurityAlgorithms.HmacSha256);

            var claims = new List<Claim>
            {
                new Claim(JwtClaimNames.UserId, UserId.ToString()),
                new Claim(JwtClaimNames.UserName, UserName),
                new Claim(JwtClaimNames.DisplayName, DisplayName),
                new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString())
            };


            DateTime expiry = DateTime.UtcNow.AddMinutes(expiryMinutes);

            var token = new JwtSecurityToken(issuer, audience, claims, expires:expiry, signingCredentials: credentials);

            return new TokenResult
            {
                AccessToken = new JwtSecurityTokenHandler().WriteToken(token),
                AccessTokenExpiry = expiry
            };
        }
    }
}
