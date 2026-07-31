using Dapper;

namespace FingersAPI.Database
{
    public interface IDbContext
    {
        Task<int> ExecuteAsync( string storedProcedure, DynamicParameters parameters );
        Task<T?> ExecuteSingleQueryAsync<T>(string storedProcedure, DynamicParameters parameters);
        
        Task <IEnumerable<T>> ExecuteQueryAsync<T>( string storedProcedure, DynamicParameters parameters );

        Task<List<T>> ExecuteQueryAsyncList<T>(string storedProcedure, DynamicParameters parameters);

    }
}
