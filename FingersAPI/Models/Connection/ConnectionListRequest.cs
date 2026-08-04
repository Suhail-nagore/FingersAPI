using FingersAPI.Common;
namespace FingersAPI.Models.Connection
{
    public class ConnectionListRequest
    {
        public ConnectionListType ListType { get; set; }
        public string? SearchText { get; set; }
    }
}