import XCTest
@testable import AuthdogSwiftSDK

final class AuthdogTypesTests: XCTestCase {
    
    func testMetaDecoding() {
        let json = """
        {
            "code": 200,
            "message": "Success"
        }
        """
        
        let data = json.data(using: .utf8)!
        let meta = try! JSONDecoder().decode(Meta.self, from: data)
        
        XCTAssertEqual(meta.code, 200)
        XCTAssertEqual(meta.message, "Success")
    }
    
    func testSessionDecoding() {
        let json = """
        {
            "remainingSeconds": 3600
        }
        """
        
        let data = json.data(using: .utf8)!
        let session = try! JSONDecoder().decode(Session.self, from: data)
        
        XCTAssertEqual(session.remainingSeconds, 3600)
    }
    
    func testNamesDecoding() {
        let json = """
        {
            "id": "name_123",
            "formatted": "John Doe",
            "familyName": "Doe",
            "givenName": "John",
            "middleName": "William",
            "honorificPrefix": "Mr.",
            "honorificSuffix": "Jr."
        }
        """
        
        let data = json.data(using: .utf8)!
        let names = try! JSONDecoder().decode(Names.self, from: data)
        
        XCTAssertEqual(names.id, "name_123")
        XCTAssertEqual(names.formatted, "John Doe")
        XCTAssertEqual(names.familyName, "Doe")
        XCTAssertEqual(names.givenName, "John")
        XCTAssertEqual(names.middleName, "William")
        XCTAssertEqual(names.honorificPrefix, "Mr.")
        XCTAssertEqual(names.honorificSuffix, "Jr.")
    }
    
    func testEmailDecoding() {
        let json = """
        {
            "id": "email_123",
            "value": "john@example.com",
            "type": "work"
        }
        """
        
        let data = json.data(using: .utf8)!
        let email = try! JSONDecoder().decode(Email.self, from: data)
        
        XCTAssertEqual(email.id, "email_123")
        XCTAssertEqual(email.value, "john@example.com")
        XCTAssertEqual(email.type, "work")
    }
    
    func testEmailDecodingWithNilType() {
        let json = """
        {
            "id": "email_123",
            "value": "john@example.com",
            "type": null
        }
        """
        
        let data = json.data(using: .utf8)!
        let email = try! JSONDecoder().decode(Email.self, from: data)
        
        XCTAssertEqual(email.id, "email_123")
        XCTAssertEqual(email.value, "john@example.com")
        XCTAssertNil(email.type)
    }
    
    func testVerificationDecoding() {
        let json = """
        {
            "id": "verification_123",
            "email": "john@example.com",
            "verified": true,
            "createdAt": "2023-01-01T00:00:00Z",
            "updatedAt": "2023-01-02T00:00:00Z"
        }
        """
        
        let data = json.data(using: .utf8)!
        let verification = try! JSONDecoder().decode(Verification.self, from: data)
        
        XCTAssertEqual(verification.id, "verification_123")
        XCTAssertEqual(verification.email, "john@example.com")
        XCTAssertTrue(verification.verified)
        XCTAssertEqual(verification.createdAt, "2023-01-01T00:00:00Z")
        XCTAssertEqual(verification.updatedAt, "2023-01-02T00:00:00Z")
    }
    
    func testUserInfoResponseDecoding() {
        let json = """
        {
            "meta": {
                "code": 200,
                "message": "Success"
            },
            "session": {
                "remainingSeconds": 3600
            },
            "user": {
                "id": "user_123",
                "externalId": "ext_123",
                "userName": "johndoe",
                "displayName": "John Doe",
                "nickName": null,
                "profileUrl": null,
                "title": null,
                "userType": null,
                "preferredLanguage": null,
                "locale": "en_US",
                "timezone": null,
                "active": true,
                "names": {
                    "id": "name_123",
                    "formatted": "John Doe",
                    "familyName": "Doe",
                    "givenName": "John",
                    "middleName": null,
                    "honorificPrefix": null,
                    "honorificSuffix": null
                },
                "photos": [],
                "phoneNumbers": [],
                "addresses": [],
                "emails": [
                    {
                        "id": "email_123",
                        "value": "john@example.com",
                        "type": "work"
                    }
                ],
                "verifications": [],
                "provider": "authdog",
                "createdAt": "2023-01-01T00:00:00Z",
                "updatedAt": "2023-01-02T00:00:00Z",
                "environmentId": "env_123"
            }
        }
        """
        
        let data = json.data(using: .utf8)!
        let response = try! JSONDecoder().decode(UserInfoResponse.self, from: data)
        
        XCTAssertEqual(response.meta.code, 200)
        XCTAssertEqual(response.session.remainingSeconds, 3600)
        XCTAssertEqual(response.user.id, "user_123")
        XCTAssertEqual(response.user.displayName, "John Doe")
        XCTAssertTrue(response.user.active)
        XCTAssertEqual(response.user.emails.count, 1)
        XCTAssertEqual(response.user.emails[0].value, "john@example.com")
    }
}
