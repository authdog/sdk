using System.Net.Http;
using System.Threading.Tasks;
using Newtonsoft.Json.Linq;

namespace Authdog
{
    /// <summary>
    /// HRIS Wave 3 operations
    /// </summary>
    public class HrisResource
    {
        private readonly AuthdogClient _client;

        public HrisResource(AuthdogClient client)
        {
            _client = client;
        }

        private string? Token(string? token) => token ?? _client.HrisToken;

        public Task<JObject> ListDepartmentsAsync(string? token = null) =>
            _client.RequestAsync<JObject>(HttpMethod.Get, "/v1/hris/v1/Departments", accessToken: Token(token));

        public JObject ListDepartments(string? token = null) =>
            ListDepartmentsAsync(token).GetAwaiter().GetResult();

        public Task<JObject> CreateDepartmentAsync(object body, string? token = null) =>
            _client.RequestAsync<JObject>(HttpMethod.Post, "/v1/hris/v1/Departments", body, accessToken: Token(token));

        public JObject CreateDepartment(object body, string? token = null) =>
            CreateDepartmentAsync(body, token).GetAwaiter().GetResult();

        public Task<JObject> GetDepartmentAsync(string departmentId, string? token = null) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Get,
                $"/v1/hris/v1/Departments/{departmentId}",
                accessToken: Token(token));

        public JObject GetDepartment(string departmentId, string? token = null) =>
            GetDepartmentAsync(departmentId, token).GetAwaiter().GetResult();

        public Task<JObject> ReplaceDepartmentAsync(string departmentId, object body, string? token = null) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Put,
                $"/v1/hris/v1/Departments/{departmentId}",
                body,
                accessToken: Token(token));

        public JObject ReplaceDepartment(string departmentId, object body, string? token = null) =>
            ReplaceDepartmentAsync(departmentId, body, token).GetAwaiter().GetResult();

        public Task<JObject> PatchDepartmentAsync(string departmentId, object body, string? token = null) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Patch,
                $"/v1/hris/v1/Departments/{departmentId}",
                body,
                accessToken: Token(token));

        public JObject PatchDepartment(string departmentId, object body, string? token = null) =>
            PatchDepartmentAsync(departmentId, body, token).GetAwaiter().GetResult();

        public Task<JObject> DeleteDepartmentAsync(string departmentId, string? token = null) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Delete,
                $"/v1/hris/v1/Departments/{departmentId}",
                accessToken: Token(token));

        public JObject DeleteDepartment(string departmentId, string? token = null) =>
            DeleteDepartmentAsync(departmentId, token).GetAwaiter().GetResult();

        public Task<JObject> ListEmployeesAsync(string? token = null) =>
            _client.RequestAsync<JObject>(HttpMethod.Get, "/v1/hris/v1/Employees", accessToken: Token(token));

        public JObject ListEmployees(string? token = null) =>
            ListEmployeesAsync(token).GetAwaiter().GetResult();

        public Task<JObject> CreateEmployeeAsync(object body, string? token = null) =>
            _client.RequestAsync<JObject>(HttpMethod.Post, "/v1/hris/v1/Employees", body, accessToken: Token(token));

        public JObject CreateEmployee(object body, string? token = null) =>
            CreateEmployeeAsync(body, token).GetAwaiter().GetResult();

        public Task<JObject> GetEmployeeAsync(string employeeId, string? token = null) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Get,
                $"/v1/hris/v1/Employees/{employeeId}",
                accessToken: Token(token));

        public JObject GetEmployee(string employeeId, string? token = null) =>
            GetEmployeeAsync(employeeId, token).GetAwaiter().GetResult();

        public Task<JObject> ReplaceEmployeeAsync(string employeeId, object body, string? token = null) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Put,
                $"/v1/hris/v1/Employees/{employeeId}",
                body,
                accessToken: Token(token));

        public JObject ReplaceEmployee(string employeeId, object body, string? token = null) =>
            ReplaceEmployeeAsync(employeeId, body, token).GetAwaiter().GetResult();

        public Task<JObject> PatchEmployeeAsync(string employeeId, object body, string? token = null) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Patch,
                $"/v1/hris/v1/Employees/{employeeId}",
                body,
                accessToken: Token(token));

        public JObject PatchEmployee(string employeeId, object body, string? token = null) =>
            PatchEmployeeAsync(employeeId, body, token).GetAwaiter().GetResult();

        public Task<JObject> DeleteEmployeeAsync(string employeeId, string? token = null) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Delete,
                $"/v1/hris/v1/Employees/{employeeId}",
                accessToken: Token(token));

        public JObject DeleteEmployee(string employeeId, string? token = null) =>
            DeleteEmployeeAsync(employeeId, token).GetAwaiter().GetResult();

        public Task<JObject> ServiceConfigAsync(string? token = null) =>
            _client.RequestAsync<JObject>(HttpMethod.Get, "/v1/hris/v1/ServiceConfig", accessToken: Token(token));

        public JObject ServiceConfig(string? token = null) =>
            ServiceConfigAsync(token).GetAwaiter().GetResult();
    }
}
