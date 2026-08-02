using Dapper;
using FingersAPI.Database;
using FingersAPI.Extensions;
using FingersAPI.Models.User;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FingersAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class UsersController : ControllerBase
    {
        private readonly IDbContext _dbContext;

        public UsersController(IDbContext dbContext)
        {
            _dbContext = dbContext;
        }

        [HttpGet("searchuser")]
        public async Task<IActionResult> SearchUser([FromQuery] string keyword)
        {
            long currentUserId = User.GetUserId();

            var parameters = new DynamicParameters();

            parameters.Add("@Keyword", keyword);
            parameters.Add("@CurrentUserId", currentUserId);

            var users = await _dbContext.ExecuteQueryAsyncList<UserSearchResult>("auth.UsersSearch", parameters);

            return Ok(users);
        }
    }
}
