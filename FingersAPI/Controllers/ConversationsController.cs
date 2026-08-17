using Dapper;
using FingersAPI.Database;
using FingersAPI.Extensions;
using FingersAPI.Models.Chat;
using FingersAPI.Models.Common;
using FingersAPI.Models.Conversation;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
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

        [HttpPost("messages")]
        public async Task<IActionResult> GetMessages([FromBody] MessagesGetRequest request)
        {
            try
            {
                var parameters = new DynamicParameters();

                parameters.Add("@CurrentUserId", User.GetUserId());
                parameters.Add("@ConversationId", request.ConversationId);
                parameters.Add("@BeforeMessageId", request.BeforeMessageId);
                parameters.Add("@PageSize", request.PageSize);

                var results = await _dbContext.ExecuteQueryAsyncList<MessageListItem>("chat.MessagesGet", parameters);

                foreach (var result in results)
                {
                    if (!string.IsNullOrWhiteSpace(result.AttachmentsJson))
                    {
                        result.Attachments = JsonSerializer.Deserialize<List<MessageAttachmentItem>>(result.AttachmentsJson) ?? new List<MessageAttachmentItem>();
                    }

                    if (!string.IsNullOrWhiteSpace(result.ReceiptsJson))
                    {
                        result.Receipts = JsonSerializer.Deserialize<List<MessageReceiptItem>>(result.ReceiptsJson) ?? new List<MessageReceiptItem>();
                    }
                }

                return Ok(new ApiResponse
                {
                    Success = true,
                    Message = "Messages retrived successfully",
                    Data = results
                });
            }
            catch (SqlException ex) when (ex.Number == 50001)
            {
                return Ok(new ApiResponse
                {
                    Success = false,
                    Message = "Invalid user.",
                    Data = null
                });
            }
            catch (SqlException ex) when (ex.Number == 50002)
            {
                return Ok(new ApiResponse
                {
                    Success = false,
                    Message = "Conversation not found.",
                    Data = null
                });
            }
            catch (SqlException ex) when (ex.Number == 50003)
            {
                return Ok(new ApiResponse
                {
                    Success = false,
                    Message = "You are not a participant of this conversation.",
                    Data = null
                });
            }
        }

        [HttpPost("messages/delivered")]
        public async Task<IActionResult> MarkMessageDelivered([FromBody] MarkMessageDeliveredRequest request)
        {
            var parameters = new DynamicParameters();
            parameters.Add("@CurrentUserId", User.GetUserId());
            parameters.Add("@MessageId", request.MessageId);
            parameters.Add("@Success", dbType: DbType.Boolean, direction: ParameterDirection.Output);
            parameters.Add("@Message", dbType:DbType.String, direction: ParameterDirection.Output, size:500);

            var result = await _dbContext.ExecuteQueryAsyncList<MarkMessageDeliveredResult>("chat.MarkMessageDelivered", parameters);

            return Ok(new ApiResponse
            {
                Success = parameters.Get<bool>("@Success"),
                Message = parameters.Get<string>("@Message"),
                Data = result
            });
        }

        [HttpPost("messages/read")]
        public async Task<IActionResult> MarkMessagesRead([FromBody] MarkMessagesReadRequest request)
        {
            var parameter = new DynamicParameters();

            parameter.Add("@CurrentUserId", User.GetUserId());
            parameter.Add("@ConversationId", request.ConversationId);
            parameter.Add("@LastReadMessageId", request.LastMessageReadId);
            parameter.Add("@Success", dbType:DbType.Boolean, direction: ParameterDirection.Output);
            parameter.Add("@Message", dbType:DbType.String,direction: ParameterDirection.Output, size:500);

            await _dbContext.ExecuteAsync("chat.MarkMessagesRead", parameter);

            return Ok(new ApiResponse
            {
                Success = parameter.Get<bool>("@Success"),
                Message = parameter.Get<string>("@Message")
            });
        }
    }
}
