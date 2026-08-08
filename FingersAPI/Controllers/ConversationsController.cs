using Dapper;
using FingersAPI.Database;
using FingersAPI.Extensions;
using FingersAPI.Models.Common;
using FingersAPI.Models.Conversation;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Data;
using System.Text.Json;

namespace FingersAPI.Controllers
{
    [Authorize]
    [Route("api/[controller]")]
    [ApiController]
    public class ConversationsController : Controller
    {
        private readonly IDbContext _dbContext;

        public ConversationsController(IDbContext dbContext) 
        { 
            _dbContext = dbContext;
        }

        [HttpPost("send-message")]
        public async Task<IActionResult> SendMessage(SendMessageRequest request)
        {
            var parameters = new DynamicParameters();

            var attachmentsJson = JsonSerializer.Serialize(request.Attachments);

            parameters.Add("@SenderUserId", User.GetUserId());
            parameters.Add("@ReceiverUserId", request.ReceiverUserId);
            parameters.Add("@ClientMessageId", request.ClientMessageId);
            parameters.Add("@MessageTypeId", request.MessageTypeId);
            parameters.Add("@Content", request.Content);
            parameters.Add("@ReplyToMessageId", request.ReplyToMessageId);
            parameters.Add("@ForwardedFromMessageId", request.ForwardedFromMessageId);
            parameters.Add("@Attachments", attachmentsJson);
            parameters.Add("@Success",dbType: DbType.Boolean,direction: ParameterDirection.Output);
            parameters.Add("@Message",dbType: DbType.String,size: 500,direction: ParameterDirection.Output);

            var result = await _dbContext.ExecuteQueryAsync<SendMessageResult>("chat.SendMessage",parameters);

            var response = new ApiResponse
            {
                Success = parameters.Get<bool>("@Success"),
                Message = parameters.Get<string>("@Message")!,
                Data = result
            };

            return Ok(response);
        }

        [HttpPost("list")]
        public async Task<IActionResult> GetConversations([FromBody] ConversationGetRequest request)
        {
            var parameters = new DynamicParameters();

            parameters.Add("@CurrentUserId",User.GetUserId());
            parameters.Add("@SearchText",request.SearchText);
            var result = await _dbContext.ExecuteQueryAsyncList<ConversationListItem>("chat.ConversationsGet",parameters);

            return Ok(new ApiResponse
            {
                Success = true,
                Message = "Conversations retrieved successfully.",
                Data = result
            });
        }
    }
}
