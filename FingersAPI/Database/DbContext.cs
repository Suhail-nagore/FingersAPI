using Dapper;
using Microsoft.Data.SqlClient;
using System.Data;

namespace FingersAPI.Database
{
    public class DbContext: IDbContext
    {
        private readonly string _connectionString;

        public DbContext(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection") ?? throw new InvalidOperationException("Default Connection is not configured");
        }

        private SqlConnection CreateConnection()
        {
            return new SqlConnection(_connectionString);
        }

        public async Task<int> ExecuteAsync( string storedProcedure, DynamicParameters parameters)
        {
            await using var connection = CreateConnection();
            await connection.OpenAsync();

            return await connection.ExecuteAsync(storedProcedure, parameters, commandType:CommandType.StoredProcedure);
        }

        public async Task<T?> ExecuteSingleQueryAsync<T>( string storedProcedure, DynamicParameters parameters)
        {
            await using var connection = CreateConnection();
            await connection.OpenAsync();

            return await connection.QueryFirstOrDefaultAsync<T>(storedProcedure, parameters, commandType: CommandType.StoredProcedure);
        }

        public async Task<IEnumerable<T>> ExecuteQueryAsync<T>(string storedProcedure, DynamicParameters parameters)
        {
            await using var connection = CreateConnection();
            await connection.OpenAsync();

            return await connection.QueryAsync<T>(storedProcedure, parameters, commandType: CommandType.StoredProcedure);
        }

        public async Task<List<T>> ExecuteQueryAsyncList<T>(string storedProcedure, DynamicParameters parameters)
        {
            await using var connection = CreateConnection();
            await connection.OpenAsync();

            var result = await connection.QueryAsync<T>(storedProcedure, parameters, commandType: CommandType.StoredProcedure);
            return result.ToList();
        }
    }
}
