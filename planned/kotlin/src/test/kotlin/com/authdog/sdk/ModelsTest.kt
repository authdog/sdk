package com.authdog.sdk

import kotlinx.serialization.json.Json
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals
import kotlin.test.assertNotNull
import kotlin.test.assertNull

class ModelsTest {

    private val json = Json {
        ignoreUnknownKeys = true
        coerceInputValues = true
    }

    @Test
    fun `UserInfoResponse can be deserialized from JSON`() {
        val jsonString = """
        {
            "meta": {"code": 200, "message": "Success"},
            "session": {"remainingSeconds": 3600},
            "user": {
                "id": "user123",
                "externalId": "ext123",
                "userName": "testuser",
                "displayName": "Test User",
                "nickName": "test",
                "profileUrl": "https://example.com/profile",
                "title": "Developer",
                "userType": "employee",
                "preferredLanguage": "en",
                "locale": "en-US",
                "timezone": "UTC",
                "active": true,
                "names": {
                    "id": "name123",
                    "formatted": "Test User",
                    "familyName": "User",
                    "givenName": "Test",
                    "middleName": "Middle",
                    "honorificPrefix": "Mr.",
                    "honorificSuffix": "Jr."
                },
                "photos": [
                    {
                        "id": "photo123",
                        "value": "https://example.com/photo.jpg",
                        "type": "profile"
                    }
                ],
                "phoneNumbers": [],
                "addresses": [],
                "emails": [
                    {
                        "id": "email123",
                        "value": "test@example.com",
                        "type": "work"
                    }
                ],
                "verifications": [
                    {
                        "id": "verification123",
                        "email": "test@example.com",
                        "verified": true,
                        "createdAt": "2023-01-01T00:00:00Z",
                        "updatedAt": "2023-01-01T00:00:00Z"
                    }
                ],
                "provider": "test",
                "createdAt": "2023-01-01T00:00:00Z",
                "updatedAt": "2023-01-01T00:00:00Z",
                "environmentId": "env123"
            }
        }
        """.trimIndent()

        val response = json.decodeFromString<UserInfoResponse>(jsonString)

        assertEquals(200, response.meta.code)
        assertEquals("Success", response.meta.message)
        assertEquals(3600, response.session.remainingSeconds)
        assertEquals("user123", response.user.id)
        assertEquals("testuser", response.user.userName)
        assertEquals("Test User", response.user.displayName)
        assertEquals("test", response.user.nickName)
        assertEquals("https://example.com/profile", response.user.profileUrl)
        assertEquals("Developer", response.user.title)
        assertEquals("employee", response.user.userType)
        assertEquals("en", response.user.preferredLanguage)
        assertEquals("en-US", response.user.locale)
        assertEquals("UTC", response.user.timezone)
        assertEquals(true, response.user.active)
        assertEquals("env123", response.user.environmentId)
    }

    @Test
    fun `UserInfoResponse handles null optional fields`() {
        val jsonString = """
        {
            "meta": {"code": 200, "message": "Success"},
            "session": {"remainingSeconds": 3600},
            "user": {
                "id": "user123",
                "externalId": "ext123",
                "userName": "testuser",
                "displayName": "Test User",
                "locale": "en-US",
                "active": true,
                "names": {
                    "id": "name123",
                    "familyName": "User",
                    "givenName": "Test"
                },
                "photos": [],
                "phoneNumbers": [],
                "addresses": [],
                "emails": [],
                "verifications": [],
                "provider": "test",
                "createdAt": "2023-01-01T00:00:00Z",
                "updatedAt": "2023-01-01T00:00:00Z",
                "environmentId": "env123"
            }
        }
        """.trimIndent()

        val response = json.decodeFromString<UserInfoResponse>(jsonString)

        assertNull(response.user.nickName)
        assertNull(response.user.profileUrl)
        assertNull(response.user.title)
        assertNull(response.user.userType)
        assertNull(response.user.preferredLanguage)
        assertNull(response.user.timezone)
        assertNull(response.user.names.formatted)
        assertNull(response.user.names.middleName)
        assertNull(response.user.names.honorificPrefix)
        assertNull(response.user.names.honorificSuffix)
    }

    @Test
    fun `Meta can be deserialized`() {
        val jsonString = """{"code": 200, "message": "Success"}"""
        val meta = json.decodeFromString<Meta>(jsonString)
        
        assertEquals(200, meta.code)
        assertEquals("Success", meta.message)
    }

    @Test
    fun `Session can be deserialized`() {
        val jsonString = """{"remainingSeconds": 3600}"""
        val session = json.decodeFromString<Session>(jsonString)
        
        assertEquals(3600, session.remainingSeconds)
    }

    @Test
    fun `Names can be deserialized with optional fields`() {
        val jsonString = """
        {
            "id": "name123",
            "formatted": "Test User",
            "familyName": "User",
            "givenName": "Test",
            "middleName": "Middle",
            "honorificPrefix": "Mr.",
            "honorificSuffix": "Jr."
        }
        """.trimIndent()
        
        val names = json.decodeFromString<Names>(jsonString)
        
        assertEquals("name123", names.id)
        assertEquals("Test User", names.formatted)
        assertEquals("User", names.familyName)
        assertEquals("Test", names.givenName)
        assertEquals("Middle", names.middleName)
        assertEquals("Mr.", names.honorificPrefix)
        assertEquals("Jr.", names.honorificSuffix)
    }

    @Test
    fun `Photo can be deserialized`() {
        val jsonString = """
        {
            "id": "photo123",
            "value": "https://example.com/photo.jpg",
            "type": "profile"
        }
        """.trimIndent()
        
        val photo = json.decodeFromString<Photo>(jsonString)
        
        assertEquals("photo123", photo.id)
        assertEquals("https://example.com/photo.jpg", photo.value)
        assertEquals("profile", photo.type)
    }

    @Test
    fun `Email can be deserialized with optional type`() {
        val jsonString = """
        {
            "id": "email123",
            "value": "test@example.com",
            "type": "work"
        }
        """.trimIndent()
        
        val email = json.decodeFromString<Email>(jsonString)
        
        assertEquals("email123", email.id)
        assertEquals("test@example.com", email.value)
        assertEquals("work", email.type)
    }

    @Test
    fun `Email can be deserialized without type`() {
        val jsonString = """
        {
            "id": "email123",
            "value": "test@example.com"
        }
        """.trimIndent()
        
        val email = json.decodeFromString<Email>(jsonString)
        
        assertEquals("email123", email.id)
        assertEquals("test@example.com", email.value)
        assertNull(email.type)
    }

    @Test
    fun `Verification can be deserialized`() {
        val jsonString = """
        {
            "id": "verification123",
            "email": "test@example.com",
            "verified": true,
            "createdAt": "2023-01-01T00:00:00Z",
            "updatedAt": "2023-01-01T00:00:00Z"
        }
        """.trimIndent()
        
        val verification = json.decodeFromString<Verification>(jsonString)
        
        assertEquals("verification123", verification.id)
        assertEquals("test@example.com", verification.email)
        assertEquals(true, verification.verified)
        assertEquals("2023-01-01T00:00:00Z", verification.createdAt)
        assertEquals("2023-01-01T00:00:00Z", verification.updatedAt)
    }

    @Test
    fun `ErrorResponse can be deserialized`() {
        val jsonString = """{"error": "GraphQL query failed"}"""
        val errorResponse = json.decodeFromString<ErrorResponse>(jsonString)
        
        assertEquals("GraphQL query failed", errorResponse.error)
    }
}
