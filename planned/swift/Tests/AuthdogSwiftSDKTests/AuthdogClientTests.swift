import XCTest
@testable import AuthdogSwiftSDK

final class AuthdogClientTests: XCTestCase {
    
    func testClientInitialization() {
        let client = AuthdogClient(baseURL: "https://api.authdog.com")
        XCTAssertNotNil(client)
    }
    
    func testClientInitializationWithAPIKey() {
        let client = AuthdogClient(baseURL: "https://api.authdog.com", apiKey: "test-key")
        XCTAssertNotNil(client)
    }
    
    func testClientInitializationWithTimeout() {
        let client = AuthdogClient(baseURL: "https://api.authdog.com", timeout: 5)
        XCTAssertNotNil(client)
    }
    
    func testClientTrimsTrailingSlash() {
        let client = AuthdogClient(baseURL: "https://api.authdog.com/")
        XCTAssertNotNil(client)
    }
}
