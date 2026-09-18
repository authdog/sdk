package com.authdog.resources;

import com.authdog.AuthdogClient;
import com.authdog.exceptions.ApiException;
import com.authdog.exceptions.AuthenticationException;
import com.fasterxml.jackson.databind.JsonNode;

/**
 * HRIS directory operations.
 */
public final class HrisResource {
    /**
     * Authdog client.
     */
    private final AuthdogClient client;

    /**
     * Create an HRIS helper.
     * @param clientParam Authdog client
     */
    public HrisResource(final AuthdogClient clientParam) {
        this.client = clientParam;
    }

    /**
     * List HRIS departments.
     * @return departments envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode listDepartments()
            throws AuthenticationException, ApiException {
        return listDepartments(null);
    }

    /**
     * List HRIS departments with a token override.
     * @param token optional HRIS token override
     * @return departments envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode listDepartments(final String token)
            throws AuthenticationException, ApiException {
        return call("GET", "/v1/hris/v1/Departments", null, token);
    }

    /**
     * Create an HRIS department.
     * @param body request body
     * @return created department envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode createDepartment(final Object body)
            throws AuthenticationException, ApiException {
        return createDepartment(body, null);
    }

    /**
     * Create an HRIS department with a token override.
     * @param body request body
     * @param token optional HRIS token override
     * @return created department envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode createDepartment(final Object body,
                                     final String token)
            throws AuthenticationException, ApiException {
        return call("POST", "/v1/hris/v1/Departments", body, token);
    }

    /**
     * Get an HRIS department.
     * @param departmentId department ID
     * @return department envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode getDepartment(final String departmentId)
            throws AuthenticationException, ApiException {
        return getDepartment(departmentId, null);
    }

    /**
     * Get an HRIS department with a token override.
     * @param departmentId department ID
     * @param token optional HRIS token override
     * @return department envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode getDepartment(final String departmentId,
                                  final String token)
            throws AuthenticationException, ApiException {
        return call("GET", "/v1/hris/v1/Departments/" + departmentId,
                null, token);
    }

    /**
     * Replace an HRIS department.
     * @param departmentId department ID
     * @param body request body
     * @return department envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode replaceDepartment(final String departmentId,
                                      final Object body)
            throws AuthenticationException, ApiException {
        return replaceDepartment(departmentId, body, null);
    }

    /**
     * Replace an HRIS department with a token override.
     * @param departmentId department ID
     * @param body request body
     * @param token optional HRIS token override
     * @return department envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode replaceDepartment(final String departmentId,
                                      final Object body,
                                      final String token)
            throws AuthenticationException, ApiException {
        return call("PUT", "/v1/hris/v1/Departments/" + departmentId,
                body, token);
    }

    /**
     * Patch an HRIS department.
     * @param departmentId department ID
     * @param body request body
     * @return department envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode patchDepartment(final String departmentId,
                                    final Object body)
            throws AuthenticationException, ApiException {
        return patchDepartment(departmentId, body, null);
    }

    /**
     * Patch an HRIS department with a token override.
     * @param departmentId department ID
     * @param body request body
     * @param token optional HRIS token override
     * @return department envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode patchDepartment(final String departmentId,
                                    final Object body,
                                    final String token)
            throws AuthenticationException, ApiException {
        return call("PATCH", "/v1/hris/v1/Departments/" + departmentId,
                body, token);
    }

    /**
     * Delete an HRIS department.
     * @param departmentId department ID
     * @return delete envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode deleteDepartment(final String departmentId)
            throws AuthenticationException, ApiException {
        return deleteDepartment(departmentId, null);
    }

    /**
     * Delete an HRIS department with a token override.
     * @param departmentId department ID
     * @param token optional HRIS token override
     * @return delete envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode deleteDepartment(final String departmentId,
                                     final String token)
            throws AuthenticationException, ApiException {
        return call("DELETE",
                "/v1/hris/v1/Departments/" + departmentId, null, token);
    }

    /**
     * List HRIS employees.
     * @return employees envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode listEmployees()
            throws AuthenticationException, ApiException {
        return listEmployees(null);
    }

    /**
     * List HRIS employees with a token override.
     * @param token optional HRIS token override
     * @return employees envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode listEmployees(final String token)
            throws AuthenticationException, ApiException {
        return call("GET", "/v1/hris/v1/Employees", null, token);
    }

    /**
     * Create an HRIS employee.
     * @param body request body
     * @return created employee envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode createEmployee(final Object body)
            throws AuthenticationException, ApiException {
        return createEmployee(body, null);
    }

    /**
     * Create an HRIS employee with a token override.
     * @param body request body
     * @param token optional HRIS token override
     * @return created employee envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode createEmployee(final Object body, final String token)
            throws AuthenticationException, ApiException {
        return call("POST", "/v1/hris/v1/Employees", body, token);
    }

    /**
     * Get an HRIS employee.
     * @param employeeId employee ID
     * @return employee envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode getEmployee(final String employeeId)
            throws AuthenticationException, ApiException {
        return getEmployee(employeeId, null);
    }

    /**
     * Get an HRIS employee with a token override.
     * @param employeeId employee ID
     * @param token optional HRIS token override
     * @return employee envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode getEmployee(final String employeeId,
                                final String token)
            throws AuthenticationException, ApiException {
        return call("GET", "/v1/hris/v1/Employees/" + employeeId, null,
                token);
    }

    /**
     * Replace an HRIS employee.
     * @param employeeId employee ID
     * @param body request body
     * @return employee envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode replaceEmployee(final String employeeId,
                                    final Object body)
            throws AuthenticationException, ApiException {
        return replaceEmployee(employeeId, body, null);
    }

    /**
     * Replace an HRIS employee with a token override.
     * @param employeeId employee ID
     * @param body request body
     * @param token optional HRIS token override
     * @return employee envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode replaceEmployee(final String employeeId,
                                    final Object body,
                                    final String token)
            throws AuthenticationException, ApiException {
        return call("PUT", "/v1/hris/v1/Employees/" + employeeId, body,
                token);
    }

    /**
     * Patch an HRIS employee.
     * @param employeeId employee ID
     * @param body request body
     * @return employee envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode patchEmployee(final String employeeId,
                                  final Object body)
            throws AuthenticationException, ApiException {
        return patchEmployee(employeeId, body, null);
    }

    /**
     * Patch an HRIS employee with a token override.
     * @param employeeId employee ID
     * @param body request body
     * @param token optional HRIS token override
     * @return employee envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode patchEmployee(final String employeeId,
                                  final Object body,
                                  final String token)
            throws AuthenticationException, ApiException {
        return call("PATCH", "/v1/hris/v1/Employees/" + employeeId,
                body, token);
    }

    /**
     * Delete an HRIS employee.
     * @param employeeId employee ID
     * @return delete envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode deleteEmployee(final String employeeId)
            throws AuthenticationException, ApiException {
        return deleteEmployee(employeeId, null);
    }

    /**
     * Delete an HRIS employee with a token override.
     * @param employeeId employee ID
     * @param token optional HRIS token override
     * @return delete envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode deleteEmployee(final String employeeId,
                                   final String token)
            throws AuthenticationException, ApiException {
        return call("DELETE", "/v1/hris/v1/Employees/" + employeeId,
                null, token);
    }

    /**
     * Get the HRIS service configuration.
     * @return configuration envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode serviceConfig()
            throws AuthenticationException, ApiException {
        return serviceConfig(null);
    }

    /**
     * Get the HRIS service configuration with a token override.
     * @param token optional HRIS token override
     * @return configuration envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode serviceConfig(final String token)
            throws AuthenticationException, ApiException {
        return call("GET", "/v1/hris/v1/ServiceConfig", null, token);
    }

    /**
     * Send an HRIS request with the HRIS token.
     * @param method HTTP method
     * @param path request path
     * @param body request body
     * @param token optional HRIS token override
     * @return response envelope
     */
    private JsonNode call(final String method, final String path,
                          final Object body, final String token) {
        final String accessToken = token != null
                ? token : client.getHrisToken();
        return client.request(method, path, body, null, JsonNode.class,
                accessToken);
    }
}
