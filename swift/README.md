# Authdog Swift SDK

Official Swift SDK for Authdog authentication and user management platform.

## Installation

### Swift Package Manager

Add the following dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/authdog/sdk.git", from: "0.1.0")
]
```

Or add it through Xcode:
1. File → Add Package Dependencies
2. Enter the repository URL: `https://github.com/authdog/sdk.git`
3. Select the version range

### CocoaPods

Add the following to your `Podfile`:

```ruby
pod 'AuthdogSwiftSDK', :git => 'https://github.com/authdog/sdk.git'
```

Then run `pod install`.

### Carthage

Add the following to your `Cartfile`:

```
git "https://github.com/authdog/sdk.git" "main"
```

Then run `carthage update`.

## Requirements

- iOS 13.0+ / macOS 10.15+ / watchOS 6.0+ / tvOS 13.0+
- Swift 5.9+
- Alamofire HTTP client

## Quick Start

```swift
import AuthdogSwiftSDK

// Initialize the client
let client = AuthdogClient(baseURL: "https://api.authdog.com")

// Get user information (async/await)
Task {
    do {
        let userInfo = try await client.getUserInfo(accessToken: "your-access-token")
        print("User: \(userInfo.user.displayName)")
    } catch AuthdogError.authenticationFailed(let message) {
        print("Authentication failed: \(message)")
    } catch AuthdogError.apiError(let message) {
        print("API error: \(message)")
    } catch {
        print("Error: \(error)")
    }
}

// Get user information (completion handler)
client.getUserInfo(accessToken: "your-access-token") { result in
    switch result {
    case .success(let userInfo):
        print("User: \(userInfo.user.displayName)")
    case .failure(let error):
        print("Error: \(error.localizedDescription)")
    }
}
```

## Configuration

### Basic Configuration

```swift
let client = AuthdogClient(baseURL: "https://api.authdog.com")
```

### With API Key

```swift
let client = AuthdogClient(baseURL: "https://api.authdog.com", apiKey: "your-api-key")
```

### Custom Timeout

```swift
let client = AuthdogClient(baseURL: "https://api.authdog.com", 
                          apiKey: "your-api-key", 
                          timeout: 30)
```

## API Reference

### AuthdogClient

#### Initializer

```swift
init(baseURL: String, apiKey: String? = nil, timeout: TimeInterval = 10)
```

Create a new Authdog client.

**Parameters:**
- `baseURL`: The base URL of the Authdog API
- `apiKey`: Optional API key for authentication
- `timeout`: Request timeout in seconds (default: 10)

#### Methods

##### getUserInfo (async/await)

```swift
func getUserInfo(accessToken: String) async throws -> UserInfoResponse
```

Get user information using an access token asynchronously.

**Parameters:**
- `accessToken`: The access token for authentication

**Returns:** `UserInfoResponse` containing user information

**Throws:**
- `AuthdogError.authenticationFailed`: When authentication fails (401 responses)
- `AuthdogError.apiError`: When API request fails

##### getUserInfo (completion handler)

```swift
func getUserInfo(accessToken: String, completion: @escaping (Result<UserInfoResponse, AuthdogError>) -> Void)
```

Get user information using an access token with completion handler.

**Parameters:**
- `accessToken`: The access token for authentication
- `completion`: Completion handler with result

## Data Types

### UserInfoResponse

```swift
public struct UserInfoResponse: Codable {
    public let meta: Meta
    public let session: Session
    public let user: User
}
```

### User

```swift
public struct User: Codable {
    public let id: String
    public let externalId: String
    public let userName: String
    public let displayName: String
    public let nickName: String?
    public let profileUrl: String?
    public let title: String?
    public let userType: String?
    public let preferredLanguage: String?
    public let locale: String
    public let timezone: String?
    public let active: Bool
    public let names: Names
    public let photos: [Photo]
    public let phoneNumbers: [String]
    public let addresses: [String]
    public let emails: [Email]
    public let verifications: [Verification]
    public let provider: String
    public let createdAt: String
    public let updatedAt: String
    public let environmentId: String
}
```

### Names

```swift
public struct Names: Codable {
    public let id: String
    public let formatted: String?
    public let familyName: String
    public let givenName: String
    public let middleName: String?
    public let honorificPrefix: String?
    public let honorificSuffix: String?
}
```

### Email

```swift
public struct Email: Codable {
    public let id: String
    public let value: String
    public let type: String?
}
```

### Photo

```swift
public struct Photo: Codable {
    public let id: String
    public let value: String
    public let type: String
}
```

### Verification

```swift
public struct Verification: Codable {
    public let id: String
    public let email: String
    public let verified: Bool
    public let createdAt: String
    public let updatedAt: String
}
```

## Error Handling

The SDK provides structured error handling with specific error types:

### Authentication Error

```swift
do {
    let userInfo = try await client.getUserInfo(accessToken: "invalid-token")
} catch AuthdogError.authenticationFailed(let message) {
    print("Authentication failed: \(message)")
}
```

### API Error

```swift
do {
    let userInfo = try await client.getUserInfo(accessToken: "valid-token")
} catch AuthdogError.apiError(let message) {
    print("API error: \(message)")
}
```

### Network Error

```swift
do {
    let userInfo = try await client.getUserInfo(accessToken: "token")
} catch AuthdogError.networkError(let message) {
    print("Network error: \(message)")
}
```

### Parse Error

```swift
do {
    let userInfo = try await client.getUserInfo(accessToken: "token")
} catch AuthdogError.parseError(let message) {
    print("Parse error: \(message)")
}
```

## Examples

### Basic Usage

```swift
import AuthdogSwiftSDK

class UserService {
    private let client: AuthdogClient
    
    init() {
        self.client = AuthdogClient(baseURL: "https://api.authdog.com")
    }
    
    func loadUserInfo(accessToken: String) async {
        do {
            let userInfo = try await client.getUserInfo(accessToken: accessToken)
            let user = userInfo.user
            
            print("User ID: \(user.id)")
            print("Display Name: \(user.displayName)")
            print("Provider: \(user.provider)")
            
            if let email = user.emails.first {
                print("Email: \(email.value)")
            }
        } catch AuthdogError.authenticationFailed(let message) {
            print("Authentication failed: \(message)")
        } catch AuthdogError.apiError(let message) {
            print("API error: \(message)")
        } catch {
            print("Unexpected error: \(error)")
        }
    }
}
```

### SwiftUI Integration

```swift
import SwiftUI
import AuthdogSwiftSDK

struct UserProfileView: View {
    @State private var userInfo: UserInfoResponse?
    @State private var errorMessage: String?
    @State private var isLoading = false
    
    private let client = AuthdogClient(baseURL: "https://api.authdog.com")
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading user info...")
            } else if let userInfo = userInfo {
                VStack(alignment: .leading, spacing: 16) {
                    Text("User Profile")
                        .font(.title)
                        .bold()
                    
                    Text("Name: \(userInfo.user.displayName)")
                    Text("Email: \(userInfo.user.emails.first?.value ?? "N/A")")
                    Text("Provider: \(userInfo.user.provider)")
                    Text("Active: \(userInfo.user.active ? "Yes" : "No")")
                }
                .padding()
            } else if let errorMessage = errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
            }
        }
        .onAppear {
            loadUserInfo()
        }
    }
    
    private func loadUserInfo() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let userInfo = try await client.getUserInfo(accessToken: "your-access-token")
                await MainActor.run {
                    self.userInfo = userInfo
                    self.isLoading = false
                }
            } catch AuthdogError.authenticationFailed(let message) {
                await MainActor.run {
                    self.errorMessage = "Authentication failed: \(message)"
                    self.isLoading = false
                }
            } catch AuthdogError.apiError(let message) {
                await MainActor.run {
                    self.errorMessage = "API error: \(message)"
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Unexpected error: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
}
```

### Combine Integration

```swift
import Combine
import AuthdogSwiftSDK

class UserViewModel: ObservableObject {
    @Published var userInfo: UserInfoResponse?
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    private let client = AuthdogClient(baseURL: "https://api.authdog.com")
    private var cancellables = Set<AnyCancellable>()
    
    func loadUserInfo(accessToken: String) {
        isLoading = true
        errorMessage = nil
        
        Future<UserInfoResponse, AuthdogError> { promise in
            Task {
                do {
                    let userInfo = try await self.client.getUserInfo(accessToken: accessToken)
                    promise(.success(userInfo))
                } catch let error as AuthdogError {
                    promise(.failure(error))
                } catch {
                    promise(.failure(.networkError("Unexpected error: \(error.localizedDescription)")))
                }
            }
        }
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            },
            receiveValue: { [weak self] userInfo in
                self?.userInfo = userInfo
            }
        )
        .store(in: &cancellables)
    }
}
```

### UIKit Integration

```swift
import UIKit
import AuthdogSwiftSDK

class UserViewController: UIViewController {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var providerLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private let client = AuthdogClient(baseURL: "https://api.authdog.com")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUserInfo()
    }
    
    private func loadUserInfo() {
        activityIndicator.startAnimating()
        
        client.getUserInfo(accessToken: "your-access-token") { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                
                switch result {
                case .success(let userInfo):
                    self?.updateUI(with: userInfo.user)
                case .failure(let error):
                    self?.showError(error.localizedDescription)
                }
            }
        }
    }
    
    private func updateUI(with user: User) {
        nameLabel.text = user.displayName
        emailLabel.text = user.emails.first?.value ?? "N/A"
        providerLabel.text = user.provider
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
```

### URLSession Alternative

```swift
import Foundation

class AuthdogURLSessionClient {
    private let baseURL: String
    private let apiKey: String?
    private let timeout: TimeInterval
    
    init(baseURL: String, apiKey: String? = nil, timeout: TimeInterval = 10) {
        self.baseURL = baseURL.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        self.apiKey = apiKey
        self.timeout = timeout
    }
    
    func getUserInfo(accessToken: String) async throws -> UserInfoResponse {
        let url = URL(string: "\(baseURL)/v1/userinfo")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("authdog-swift-sdk/0.1.0", forHTTPHeaderField: "User-Agent")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = timeout
        
        if let apiKey = apiKey {
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthdogError.networkError("Invalid response")
        }
        
        switch httpResponse.statusCode {
        case 200:
            do {
                return try JSONDecoder().decode(UserInfoResponse.self, from: data)
            } catch {
                throw AuthdogError.parseError("Failed to parse response: \(error.localizedDescription)")
            }
        case 401:
            throw AuthdogError.authenticationFailed("Unauthorized - invalid or expired token")
        case 500:
            if let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let errorMessage = errorData["error"] as? String {
                switch errorMessage {
                case "GraphQL query failed":
                    throw AuthdogError.apiError("GraphQL query failed")
                case "Failed to fetch user info":
                    throw AuthdogError.apiError("Failed to fetch user info")
                default:
                    throw AuthdogError.apiError("HTTP error 500: \(errorMessage)")
                }
            } else {
                throw AuthdogError.apiError("HTTP error 500")
            }
        default:
            throw AuthdogError.apiError("HTTP error \(httpResponse.statusCode)")
        }
    }
}
```

## Building and Testing

### Build the Package

```bash
swift build
```

### Run Tests

```bash
swift test
```

### Generate Documentation

```bash
swift package generate-documentation
```

## Development

### Requirements

- Swift 5.9+
- Xcode 15+
- Alamofire 5.8.0+
- iOS 13.0+ / macOS 10.15+ / watchOS 6.0+ / tvOS 13.0+

### Code Style

- Follow Swift API Design Guidelines
- Use `swiftformat` for formatting
- Use `swiftlint` for linting
- Use meaningful variable and function names
- Use `struct` for data models
- Use `async/await` for asynchronous operations
- Prefer `let` over `var` for immutable values

### Running Tests

```bash
# Run all tests
swift test

# Run specific test
swift test --filter AuthdogClientTests

# Run tests with coverage
swift test --enable-code-coverage
```

## License

MIT License - see [LICENSE](../LICENSE) for details.
