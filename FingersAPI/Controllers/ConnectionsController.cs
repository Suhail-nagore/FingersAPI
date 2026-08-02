using Dapper;
using FingersAPI.Database;
using FingersAPI.Extensions;
using FingersAPI.Models.Common;
using FingersAPI.Models.Connection;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Data;

namespace FingersAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class ConnectionsController : ControllerBase
    {
        private readonly IDbContext _dbContext;

        public ConnectionsController(IDbContext dbContext)
        {
            _dbContext = dbContext;
        }

        [HttpPost("send-request")]
        public async Task<IActionResult> SendConnectionRequest(SendConnectionRequest request )
        {
            var parameters = new DynamicParameters();
            parameters.Add("@SenderUserId", User.GetUserId());
            parameters.Add("@ReceiverUserId", request.ReceiverUserId);

            parameters.Add("@Success", dbType:DbType.Boolean, direction:ParameterDirection.Output);
            parameters.Add("@Message", dbType:DbType.String, size:500, direction:ParameterDirection.Output);

            await _dbContext.ExecuteAsync("chat.SendConnectionRequest", parameters);

            var response = new ApiResponse
            {
                Success = parameters.Get<bool>("@Success"),
                Message = parameters.Get<string>("@Message"),
            };

            return Ok(response);
        }
    }
}
