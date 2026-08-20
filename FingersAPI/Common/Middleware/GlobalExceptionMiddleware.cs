using System.Text.Json;
using Microsoft.Data.SqlClient;
using FingersAPI.Common.Errors;

namespace FingersAPI.Common.Middleware
{
    public class GlobalExceptionMiddleware
    {
        private readonly RequestDelegate _next;
        private readonly ILogger<GlobalExceptionMiddleware> _logger;

        public GlobalExceptionMiddleware(
            RequestDelegate next,
            ILogger<GlobalExceptionMiddleware> logger)
        {
            _next = next;
            _logger = logger;
        }

        public async Task InvokeAsync(HttpContext context)
        {
            try
            {
                await _next(context);
            }
            catch (SqlException ex)
            {
                _logger.LogError(
                    ex,
                    "Database exception occurred. SQL Error Number: {ErrorNumber}",
                    ex.Number);

                if (AttachmentErrorMappings.TryGet(
                    ex.Number,
                    out var statusCode,
                    out var message))
                {
                    await WriteResponseAsync(
                        context,
                        statusCode,
                        message);

                    return;
                }

                await WriteResponseAsync(
                    context,
                    StatusCodes.Status500InternalServerError,
                    "An unexpected database error occurred.");
            }
            catch (Exception ex)
            {
                _logger.LogError(
                    ex,
                    "Unhandled exception occurred.");

                await WriteResponseAsync(
                    context,
                    StatusCodes.Status500InternalServerError,
                    "An unexpected error occurred.");
            }
        }

        private static async Task WriteResponseAsync(
            HttpContext context,
            int statusCode,
            string message)
        {
            if (context.Response.HasStarted)
            {
                return;
            }

            context.Response.StatusCode = statusCode;
            context.Response.ContentType = "application/json";

            var response = new
            {
                success = false,
                message,
                data = (object?)null
            };

            await context.Response.WriteAsync(
                JsonSerializer.Serialize(response));
        }
    }
}