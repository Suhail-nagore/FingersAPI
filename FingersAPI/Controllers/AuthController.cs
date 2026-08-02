using Dapper;
using FingersAPI.Common.Constants;
using FingersAPI.Database;
using FingersAPI.Models.Auth;
using FingersAPI.Models.Common;
using FingersAPI.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Data;
using System.IdentityModel.Tokens.Jwt;

namespace FingersAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly IDbContext _dbContext;
        private readonly IPasswordService _passwordService;
        private readonly ITokenService _tokenService;

        public AuthController(IDbContext dbContext, IPasswordService passwordService, ITokenService tokenService)
        {
            _dbContext = dbContext;
            _passwordService = passwordService;
            _tokenService = tokenService;
        }


        [HttpPost("register")]
        public async Task<IActionResult> Register(RegisterRequest request)
        {
            var passwordHash = _passwordService.HashPassword(request.Password);
            var parameters = new DynamicParameters();

            parameters.Add("@UserName", request.UserName, DbType.String);
            parameters.Add("@DisplayName", request.DisplayName, DbType.String);
            parameters.Add("@Email", request.Email, DbType.String);
            parameters.Add("@PasswordHash", passwordHash, DbType.String);

            parameters.Add("@Success",dbType: DbType.Boolean,direction: ParameterDirection.Output);
            parameters.Add("@Message",dbType: DbType.String,size: 500,direction: ParameterDirection.Output);


            await _dbContext.ExecuteAsync("auth.UserRegister", parameters);

            var response = new ApiResponse
            {
                Success = parameters.Get<bool>("@Success"),
                Message = parameters.Get<string>("@Message"),
            };

            return Ok(response);
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login(LoginRequest request)
        {
            var parameters = new DynamicParameters();

            parameters.Add("@UserName", request.UserName, DbType.String);
            parameters.Add("@Success", dbType:DbType.Boolean,direction: ParameterDirection.Output);
            parameters.Add("@Message", dbType:DbType.String, direction: ParameterDirection.Output, size:500);

            UserLoginResult? user = await _dbContext.ExecuteSingleQueryAsync<UserLoginResult>("auth.UserLogin", parameters);

            if (!parameters.Get<bool>("@Success") || user == null)
            {
                return Ok(new ApiResponse
                {
                    Success = false,
                    Message = parameters.Get<string>("@Message")!
                });
            }

            bool isPasswordValid = _passwordService.VerifyPassword(request.Password, user.PasswordHash);

            if (!isPasswordValid)
            {
                return Ok(new ApiResponse
                {
                    Success = false,
                    Message = "Invalid Username or password"
                });
                
            }

            TokenResult token = _tokenService.GenerateToken(user.UserId, user.UserName, user.DisplayName);


            LoginResponse response = new()
            {
                Success = true,
                Message = "Login Successfull",
                UserId = user.UserId,
                UserName = user.UserName,
                DisplayName = user.DisplayName,
                AccessToken = token.AccessToken,
                AccessTokenExpiry = token.AccessTokenExpiry,
            };

            return Ok(response);
        }

        [Authorize]
        [HttpGet("me")]
        public IActionResult Me()
        {
            return Ok(new
            {
                UserId = User.FindFirst(JwtClaimNames.UserId)?.Value,
                UserName = User.FindFirst(JwtClaimNames.UserName)?.Value,
                DisplayName = User.FindFirst(JwtClaimNames.DisplayName)?.Value
            });
        }

    }
}
