import Foundation

/// Metadata in the response
public struct Meta: Codable {
    public let code: Int
    public let message: String
    
    public init(code: Int, message: String) {
        self.code = code
        self.message = message
    }
}

/// Session information
public struct AuthdogSession: Codable {
    public let remainingSeconds: Int
    
    public init(remainingSeconds: Int) {
        self.remainingSeconds = remainingSeconds
    }
}

/// User name information
public struct Names: Codable {
    public let id: String
    public let formatted: String?
    public let familyName: String
    public let givenName: String
    public let middleName: String?
    public let honorificPrefix: String?
    public let honorificSuffix: String?
    
    public init(id: String, formatted: String?, familyName: String, givenName: String, 
                middleName: String?, honorificPrefix: String?, honorificSuffix: String?) {
        self.id = id
        self.formatted = formatted
        self.familyName = familyName
        self.givenName = givenName
        self.middleName = middleName
        self.honorificPrefix = honorificPrefix
        self.honorificSuffix = honorificSuffix
    }
}

/// User photo
public struct Photo: Codable {
    public let id: String
    public let value: String
    public let type: String
    
    public init(id: String, value: String, type: String) {
        self.id = id
        self.value = value
        self.type = type
    }
}

/// User email
public struct Email: Codable {
    public let id: String
    public let value: String
    public let type: String?
    
    public init(id: String, value: String, type: String?) {
        self.id = id
        self.value = value
        self.type = type
    }
}

/// Email verification status
public struct Verification: Codable {
    public let id: String
    public let email: String
    public let verified: Bool
    public let createdAt: String
    public let updatedAt: String
    
    public init(id: String, email: String, verified: Bool, createdAt: String, updatedAt: String) {
        self.id = id
        self.email = email
        self.verified = verified
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

/// User information
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
    
    public init(id: String, externalId: String, userName: String, displayName: String, 
                nickName: String?, profileUrl: String?, title: String?, userType: String?,
                preferredLanguage: String?, locale: String, timezone: String?, active: Bool,
                names: Names, photos: [Photo], phoneNumbers: [String], addresses: [String],
                emails: [Email], verifications: [Verification], provider: String,
                createdAt: String, updatedAt: String, environmentId: String) {
        self.id = id
        self.externalId = externalId
        self.userName = userName
        self.displayName = displayName
        self.nickName = nickName
        self.profileUrl = profileUrl
        self.title = title
        self.userType = userType
        self.preferredLanguage = preferredLanguage
        self.locale = locale
        self.timezone = timezone
        self.active = active
        self.names = names
        self.photos = photos
        self.phoneNumbers = phoneNumbers
        self.addresses = addresses
        self.emails = emails
        self.verifications = verifications
        self.provider = provider
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.environmentId = environmentId
    }
}

/// Response from the /v1/userinfo endpoint
public struct UserInfoResponse: Codable {
    public let meta: Meta
    public let session: AuthdogSession
    public let user: User
    
    public init(meta: Meta, session: AuthdogSession, user: User) {
        self.meta = meta
        self.session = session
        self.user = user
    }
}
