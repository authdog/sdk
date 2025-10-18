import Foundation
import Alamofire

typealias HTTPSession = Alamofire.Session

/// Main client for interacting with Authdog API
public class AuthdogClient {
    private let baseURL: String
    private let apiKey: String?
    private let timeout: TimeInterval
    private let session: HTTPSession
    
    /// Initialize the Authdog client
    /// - Parameters:
    ///   - baseURL: The base URL of the Authdog API
    ///   - apiKey: Optional API key for authentication
    ///   - timeout: Request timeout in seconds (default: 10)
    public init(baseURL: String, apiKey: String? = nil, timeout: TimeInterval = 10) {
        self.baseURL = baseURL.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        self.apiKey = apiKey
        self.timeout = timeout
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = timeout
        configuration.timeoutIntervalForResource = timeout
        self.session = Session(configuration: configuration)
    }
    
    /// Get user information using an access token
    /// - Parameter accessToken: The access token for authentication
    /// - Returns: UserInfoResponse containing user information
    /// - Throws: AuthdogError for various error conditions
    public func getUserInfo(accessToken: String) async throws -> UserInfoResponse {
        let url = "\(baseURL)/v1/userinfo"
        
        var headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "User-Agent": "authdog-swift-sdk/0.1.0",
            "Authorization": "Bearer \(accessToken)"
        ]
        
        // Add API key if provided
        if let apiKey = apiKey {
            headers["Authorization"] = "Bearer \(apiKey)"
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            session.request(url, method: .get, headers: headers)
                .validate()
                .responseData { response in
                    switch response.result {
                    case .success(let data):
                        do {
                            let userInfo = try JSONDecoder().decode(UserInfoResponse.self, from: data)
                            continuation.resume(returning: userInfo)
                        } catch {
                            continuation.resume(throwing: AuthdogError.parseError("Failed to parse response: \(error.localizedDescription)"))
                        }
                    case .failure(let error):
                        if let statusCode = response.response?.statusCode {
                            switch statusCode {
                            case 401:
                                continuation.resume(throwing: AuthdogError.authenticationFailed("Unauthorized - invalid or expired token"))
                            case 500:
                                if let data = response.data,
                                   let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                                   let errorMessage = errorData["error"] as? String {
                                    switch errorMessage {
                                    case "GraphQL query failed":
                                        continuation.resume(throwing: AuthdogError.apiError("GraphQL query failed"))
                                    case "Failed to fetch user info":
                                        continuation.resume(throwing: AuthdogError.apiError("Failed to fetch user info"))
                                    default:
                                        continuation.resume(throwing: AuthdogError.apiError("HTTP error 500: \(errorMessage)"))
                                    }
                                } else {
                                    continuation.resume(throwing: AuthdogError.apiError("HTTP error 500"))
                                }
                            default:
                                continuation.resume(throwing: AuthdogError.apiError("HTTP error \(statusCode)"))
                            }
                        } else {
                            continuation.resume(throwing: AuthdogError.networkError("Request failed: \(error.localizedDescription)"))
                        }
                    }
                }
        }
    }
    
    /// Get user information using an access token (completion handler version)
    /// - Parameters:
    ///   - accessToken: The access token for authentication
    ///   - completion: Completion handler with result
    public func getUserInfo(accessToken: String, completion: @escaping (Result<UserInfoResponse, AuthdogError>) -> Void) {
        Task {
            do {
                let userInfo = try await getUserInfo(accessToken: accessToken)
                completion(.success(userInfo))
            } catch let error as AuthdogError {
                completion(.failure(error))
            } catch {
                completion(.failure(.networkError("Unexpected error: \(error.localizedDescription)")))
            }
        }
    }
}
