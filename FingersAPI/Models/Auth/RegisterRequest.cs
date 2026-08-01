using System.ComponentModel.DataAnnotations;

namespace FingersAPI.Models.Auth
{
    public class RegisterRequest
    {
        [Required]
        [StringLength(100)]
        public string UserName { get; set; } = string.Empty;
        [Required]
        [StringLength (100)]
        public string Password { get; set; } = string.Empty;

        [Required]
        [StringLength(100)]
        public string DisplayName {  get; set; } = string.Empty;

        [Required]
        [StringLength(320)]
        public string Email {  get; set; } = string.Empty;


    }
}
