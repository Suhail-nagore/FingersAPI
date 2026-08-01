using Dapper;
using FingersAPI.Database;
using FingersAPI.Models.Auth;
using FingersAPI.Models.Common;
using FingersAPI.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;
using System.Data;

namespace FingersAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly IDbContext _dbContext;
        private readonly IPasswordService _passwordService;

        public AuthController(IDbContext dbContext, IPasswordService passwordService)
        {
            _dbContext = dbContext;
            _passwordService = passwordService;
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

    }
}
