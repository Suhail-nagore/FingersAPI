using Microsoft.AspNetCore.Mvc;
using Dapper;
using FingersAPI.Database;
using FingersAPI.Models.Test;


namespace FingersAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class DatabaseController : ControllerBase
    {
        private readonly IDbContext _dbContext;

        public DatabaseController(IDbContext dbContext)
        {
            _dbContext = dbContext;
        }

        [HttpGet("testConnection")]
        public async Task<IActionResult> TestConnection() 
        {
            var parameter = new DynamicParameters();

            var result = await _dbContext.ExecuteSingleQueryAsync<DatabaseConnectionTestResponse>("dbo.DatabaseConnectionTest", parameter);

            return Ok(result);
        }
    }
}
