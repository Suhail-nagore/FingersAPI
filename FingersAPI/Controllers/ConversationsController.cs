using Dapper;
using FingersAPI.Database;
using FingersAPI.Extensions;
using FingersAPI.Models.Chat;
using FingersAPI.Models.Common;
using FingersAPI.Models.Configuration;
using FingersAPI.Models.Conversation;
using FingersAPI.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Options;
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
        private readonly IFileStorageService _fileStorageService;
        private readonly CloudinarySettings _cloudinarySettings;

        public ConversationsController(IDbContext dbContext, IFileStorageService fileStorageService, IOptions<CloudinarySettings> cloudinaryOptions) 
        { 
            _dbContext = dbContext;
            _fileStorageService = fileStorageService;
            _cloudinarySettings = cloudinaryOptions.Value;
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
            var parameters = new DynamicParameters();

            parameters.Add("@CurrentUserId", User.GetUserId());
            parameters.Add("@ConversationId", request.ConversationId);
            parameters.Add("@LastReadMessageId", request.LastMessageReadId);
            parameters.Add("@Success", dbType:DbType.Boolean, direction: ParameterDirection.Output);
            parameters.Add("@Message", dbType:DbType.String,direction: ParameterDirection.Output, size:500);

            await _dbContext.ExecuteAsync("chat.MarkMessagesRead", parameters);

            return Ok(new ApiResponse
            {
                Success = parameters.Get<bool>("@Success"),
                Message = parameters.Get<string>("@Message")
            });
        }

        [HttpPost("messages/edit")]
        public async Task<IActionResult> EditMessage([FromBody] EditMessageRequest request)
        {
            var parameters = new DynamicParameters();

            parameters.Add("@CurrentUserId", User.GetUserId());
            parameters.Add("@MessageId", request.MessageId);
            parameters.Add("@Content", request.Content);
            parameters.Add("@Success", dbType:DbType.Boolean, direction: ParameterDirection.Output);
            parameters.Add("@Message", dbType:DbType.String, direction: ParameterDirection.Output, size:500);

            await _dbContext.ExecuteAsync("chat.EditMessage", parameters);

            return Ok(new ApiResponse
            {
                Success = parameters.Get<bool>("@Success"),
                Message = parameters.Get<string>("@Message")
            });
        }

        [HttpPost("messages/delete")]
        public async Task<IActionResult> DeleteMessage([FromBody] DeleteMessageRequest request)
        {
            var parameters = new DynamicParameters();

            parameters.Add("@CurrentUserId", User.GetUserId());
            parameters.Add("@MessageId", request.MessageId);
            parameters.Add("@Success", dbType: DbType.Boolean, direction: ParameterDirection.Output);
            parameters.Add("@Message", dbType: DbType.String, direction: ParameterDirection.Output, size: 500);

            await _dbContext.ExecuteAsync("chat.DeleteMessage", parameters);

            return Ok(new ApiResponse
            {
                Success = parameters.Get<bool>("@Success"),
                Message = parameters.Get<string>("@Message")
            });
        }

        [HttpPost("attachements/upload-signature")]
        public async Task<IActionResult> GenerateAttachementUploadSignature([FromBody] AttachementUploadSignatureRequest request)
        {
            if( request == null)
            {
                return BadRequest(new ApiResponse
                {
                    Success = false,
                    Message = "Request is required"
                });
            }

            var resourceType = request.ResourceType?.Trim().ToLowerInvariant();

            if(resourceType != "image" && resourceType != "video")
            {
                return BadRequest(new ApiResponse
                {
                    Success = false,
                    Message = "Only image and video uploads are currently supported"
                });
            }

            var timeStamp = DateTimeOffset.UtcNow.ToUnixTimeSeconds();

            var folder = "chat-media";
            var parameters = new Dictionary<string, object>
            {
                ["timeStamp"] = timeStamp,
                ["folder"] = folder,
            };

            var signature = _fileStorageService.GenerateUploadSignature(parameters);

            return Ok(new ApiResponse
            {
                Success = true,
                Message = "Upload signature generated successfully",
                Data = new AttachementUploadSignatureResponse
                {
                    Signature = signature,
                    TimeStamp = timeStamp,
                    CloudName = _cloudinarySettings.CloudName,
                    ApiKey = _cloudinarySettings.ApiKey,
                    ResourceType = resourceType,
                    Folder = folder
                }
            });

        }

        [HttpPost("attachments")]
        public async Task<IActionResult> CreateAttachments([FromBody] AttachmentCreateRequest request)
        {
            var currentUserId = User.GetUserId();

            var parameters = new DynamicParameters();

            parameters.Add("@UploadedByUserId", currentUserId);
            parameters.Add("@PublicId", request.PublicId);
            parameters.Add("@FileName", request.FileName);
            parameters.Add("@OriginalFileName", request.OriginalFileName);
            parameters.Add("@contentType", request.ContentType);
            parameters.Add("@FileExtension", request.FileExtension);
            parameters.Add("@FileSize", request.FileSize);
            parameters.Add("@StoragePath", request.StoragePath);
            parameters.Add("@ThumbnailPath", request.ThumbnailPath);
            parameters.Add("@DurationInSeconds", request.DurationInSeconds);
            parameters.Add("@Width", request.Width);
            parameters.Add("@Height", request.Height);

            var result = await _dbContext.ExecuteQueryAsyncList<AttachmentCreateResponse>("chat.MessageAttachmentsCreate", parameters);

            var attachments = result.FirstOrDefault();

            if(attachments == null)
            {
                return StatusCode(StatusCodes.Status500InternalServerError, new ApiResponse
                {
                    Success = false,
                    Message = "Attachment could not be created",
                });
            }

            return Ok(new ApiResponse
            {
                Success = true,
                Message = "Atttachment created successfully.",
                Data = attachments
            });
        }

    }
}
