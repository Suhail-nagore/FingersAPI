using FingersAPI.Services;
using FingersAPI.Services.Interfaces;

namespace FingersAPI.Extensions
{
    public static class ServiceCollectionExtensions
    {
        public static IServiceCollection AddApplicationServices(this IServiceCollection services)
        {
            services.AddScoped<IPasswordService, PasswordService>();
            return services;
        }
    }
}
