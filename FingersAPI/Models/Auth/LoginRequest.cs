using System.ComponentModel.DataAnnotations;

namespace FingersAPI.Models.Auth
{
    public class LoginRequest
    {
        [Required]
        [StringLength(100)]
        public string UserName { get; set; } = string.Empty;

        [Required]
        [StringLength(100)]
        public string Password { get; set; } = string.Empty;

    }
}
