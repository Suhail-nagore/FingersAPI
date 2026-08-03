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

        [HttpGet("pending-request")]
        public async Task<IActionResult> GetPendingRequests()
        {
            var parameter = new DynamicParameters();

            parameter.Add("@ReceiverUserId", User.GetUserId());

            var pendingRequests = await _dbContext.ExecuteQueryAsyncList<PendingConnectionRequestResult>("chat.PendingConnectionRequests", parameter);

            return Ok(pendingRequests);

        }


        [HttpPost("action")]
        public async Task<IActionResult> ConnectionAction(ConnectionActionRequest request)
        {
            var parameters = new DynamicParameters();

            parameters.Add("@ConnectionId", request.ConnectionId);

            parameters.Add("@CurrentUserId", User.GetUserId());

            parameters.Add("@Action", request.Action.ToString());

            parameters.Add("@Success",dbType: DbType.Boolean,direction: ParameterDirection.Output);

            parameters.Add("@Message",dbType: DbType.String,size: 500,direction: ParameterDirection.Output);

            await _dbContext.ExecuteAsync("chat.ConnectionAction",parameters);

            var response = new ApiResponse
            {
                Success = parameters.Get<bool>("@Success"),
                Message = parameters.Get<string>("@Message")!
            };

            return Ok(response);
        }
    }
}
