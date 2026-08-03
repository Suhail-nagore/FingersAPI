using FingersAPI.Common;

namespace FingersAPI.Models.Connection
{
    public class ConnectionActionRequest
    {
        public long ConnectionId { get; set; }
        public ConnectionAction Action { get; set; }
    }
}
