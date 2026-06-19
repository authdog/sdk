import Foundation

/// Base error type for all Authdog SDK errors
public enum AuthdogError: Error, LocalizedError {
    case authenticationFailed(String)
    case apiError(String)
    case networkError(String)
    case parseError(String)
    case invalidToken(String)
    
    public var errorDescription: String? {
        switch self {
        case .authenticationFailed(let message):
            return "Authentication failed: \(message)"
        case .apiError(let message):
            return "API error: \(message)"
        case .networkError(let message):
            return "Network error: \(message)"
        case .parseError(let message):
            return "Parse error: \(message)"
        case .invalidToken(let message):
            return "Invalid token: \(message)"
        }
    }
}
