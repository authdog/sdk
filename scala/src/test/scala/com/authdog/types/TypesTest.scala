package com.authdog.types

import io.circe.parser.decode
import io.circe.syntax._
import org.scalatest.flatspec.AnyFlatSpec
import org.scalatest.matchers.should.Matchers

class TypesTest extends AnyFlatSpec with Matchers {
  
  "Meta" should "be decoded from JSON" in {
    val json = """{"code": 200, "message": "Success"}"""
    val result = decode[Meta](json)
    
    result shouldBe a[Right[_, _]]
    result.right.get.code shouldBe 200
    result.right.get.message shouldBe "Success"
  }
  
  it should "be encoded to JSON" in {
    val meta = Meta(200, "Success")
    val json = meta.asJson.noSpaces
    
    json should include(""""code":200""")
    json should include(""""message":"Success"""")
  }
  
  "Session" should "be decoded from JSON" in {
    val json = """{"remainingSeconds": 3600}"""
    val result = decode[Session](json)
    
    result shouldBe a[Right[_, _]]
    result.right.get.remainingSeconds shouldBe 3600
  }
  
  it should "be encoded to JSON" in {
    val session = Session(3600)
    val json = session.asJson.noSpaces
    
    json should include(""""remainingSeconds":3600""")
  }
  
  "Names" should "be decoded from JSON" in {
    val json = """{
      "id": "name_123",
      "formatted": "John Doe",
      "familyName": "Doe",
      "givenName": "John",
      "middleName": "William",
      "honorificPrefix": "Mr.",
      "honorificSuffix": "Jr."
    }"""
    val result = decode[Names](json)
    
    result shouldBe a[Right[_, _]]
    val names = result.right.get
    names.id shouldBe "name_123"
    names.formatted shouldBe Some("John Doe")
    names.familyName shouldBe "Doe"
    names.givenName shouldBe "John"
    names.middleName shouldBe Some("William")
    names.honorificPrefix shouldBe Some("Mr.")
    names.honorificSuffix shouldBe Some("Jr.")
  }
  
  it should "be encoded to JSON" in {
    val names = Names(
      id = "name_123",
      formatted = Some("John Doe"),
      familyName = "Doe",
      givenName = "John",
      middleName = Some("William"),
      honorificPrefix = Some("Mr."),
      honorificSuffix = Some("Jr.")
    )
    val json = names.asJson.noSpaces
    
    json should include(""""id":"name_123"""")
    json should include(""""formatted":"John Doe"""")
    json should include(""""familyName":"Doe"""")
    json should include(""""givenName":"John"""")
  }
  
  "Photo" should "be decoded from JSON" in {
    val json = """{
      "id": "photo_123",
      "value": "https://example.com/photo.jpg",
      "type": "profile"
    }"""
    val result = decode[Photo](json)
    
    result shouldBe a[Right[_, _]]
    val photo = result.right.get
    photo.id shouldBe "photo_123"
    photo.value shouldBe "https://example.com/photo.jpg"
    photo.`type` shouldBe "profile"
  }
  
  it should "be encoded to JSON" in {
    val photo = Photo("photo_123", "https://example.com/photo.jpg", "profile")
    val json = photo.asJson.noSpaces
    
    json should include(""""id":"photo_123"""")
    json should include(""""value":"https://example.com/photo.jpg"""")
    json should include(""""type":"profile"""")
  }
  
  "Email" should "be decoded from JSON" in {
    val json = """{
      "id": "email_123",
      "value": "john@example.com",
      "type": "work"
    }"""
    val result = decode[Email](json)
    
    result shouldBe a[Right[_, _]]
    val email = result.right.get
    email.id shouldBe "email_123"
    email.value shouldBe "john@example.com"
    email.`type` shouldBe Some("work")
  }
  
  it should "handle null type in JSON" in {
    val json = """{
      "id": "email_123",
      "value": "john@example.com",
      "type": null
    }"""
    val result = decode[Email](json)
    
    result shouldBe a[Right[_, _]]
    val email = result.right.get
    email.id shouldBe "email_123"
    email.value shouldBe "john@example.com"
    email.`type` shouldBe None
  }
  
  it should "be encoded to JSON" in {
    val email = Email("email_123", "john@example.com", Some("work"))
    val json = email.asJson.noSpaces
    
    json should include(""""id":"email_123"""")
    json should include(""""value":"john@example.com"""")
    json should include(""""type":"work"""")
  }
  
  "Verification" should "be decoded from JSON" in {
    val json = """{
      "id": "verification_123",
      "email": "john@example.com",
      "verified": true,
      "createdAt": "2023-01-01T00:00:00Z",
      "updatedAt": "2023-01-02T00:00:00Z"
    }"""
    val result = decode[Verification](json)
    
    result shouldBe a[Right[_, _]]
    val verification = result.right.get
    verification.id shouldBe "verification_123"
    verification.email shouldBe "john@example.com"
    verification.verified shouldBe true
    verification.createdAt shouldBe "2023-01-01T00:00:00Z"
    verification.updatedAt shouldBe "2023-01-02T00:00:00Z"
  }
  
  it should "be encoded to JSON" in {
    val verification = Verification(
      id = "verification_123",
      email = "john@example.com",
      verified = true,
      createdAt = "2023-01-01T00:00:00Z",
      updatedAt = "2023-01-02T00:00:00Z"
    )
    val json = verification.asJson.noSpaces
    
    json should include(""""id":"verification_123"""")
    json should include(""""email":"john@example.com"""")
    json should include(""""verified":true""")
    json should include(""""createdAt":"2023-01-01T00:00:00Z"""")
    json should include(""""updatedAt":"2023-01-02T00:00:00Z"""")
  }
  
  "User" should "be decoded from JSON" in {
    val json = """{
      "id": "user_123",
      "externalId": "ext_123",
      "userName": "johndoe",
      "displayName": "John Doe",
      "nickName": "Johnny",
      "profileUrl": "https://example.com/profile",
      "title": "Software Engineer",
      "userType": "employee",
      "preferredLanguage": "en",
      "locale": "en_US",
      "timezone": "UTC",
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
      "photos": [
        {
          "id": "photo_123",
          "value": "https://example.com/photo.jpg",
          "type": "profile"
        }
      ],
      "phoneNumbers": [],
      "addresses": [],
      "emails": [
        {
          "id": "email_123",
          "value": "john@example.com",
          "type": "work"
        }
      ],
      "verifications": [
        {
          "id": "verification_123",
          "email": "john@example.com",
          "verified": true,
          "createdAt": "2023-01-01T00:00:00Z",
          "updatedAt": "2023-01-02T00:00:00Z"
        }
      ],
      "provider": "authdog",
      "createdAt": "2023-01-01T00:00:00Z",
      "updatedAt": "2023-01-02T00:00:00Z",
      "environmentId": "env_123"
    }"""
    val result = decode[User](json)
    
    result shouldBe a[Right[_, _]]
    val user = result.right.get
    user.id shouldBe "user_123"
    user.externalId shouldBe "ext_123"
    user.userName shouldBe "johndoe"
    user.displayName shouldBe "John Doe"
    user.nickName shouldBe Some("Johnny")
    user.profileUrl shouldBe Some("https://example.com/profile")
    user.title shouldBe Some("Software Engineer")
    user.userType shouldBe Some("employee")
    user.preferredLanguage shouldBe Some("en")
    user.locale shouldBe "en_US"
    user.timezone shouldBe Some("UTC")
    user.active shouldBe true
    user.provider shouldBe "authdog"
    user.createdAt shouldBe "2023-01-01T00:00:00Z"
    user.updatedAt shouldBe "2023-01-02T00:00:00Z"
    user.environmentId shouldBe "env_123"
    
    // Test nested structures
    user.names.id shouldBe "name_123"
    user.names.givenName shouldBe "John"
    user.names.familyName shouldBe "Doe"
    
    user.photos should have size 1
    user.photos.head.id shouldBe "photo_123"
    user.photos.head.value shouldBe "https://example.com/photo.jpg"
    
    user.emails should have size 1
    user.emails.head.id shouldBe "email_123"
    user.emails.head.value shouldBe "john@example.com"
    
    user.verifications should have size 1
    user.verifications.head.id shouldBe "verification_123"
    user.verifications.head.verified shouldBe true
  }
  
  it should "be encoded to JSON" in {
    val user = User(
      id = "user_123",
      externalId = "ext_123",
      userName = "johndoe",
      displayName = "John Doe",
      nickName = Some("Johnny"),
      profileUrl = Some("https://example.com/profile"),
      title = Some("Software Engineer"),
      userType = Some("employee"),
      preferredLanguage = Some("en"),
      locale = "en_US",
      timezone = Some("UTC"),
      active = true,
      names = Names(
        id = "name_123",
        formatted = Some("John Doe"),
        familyName = "Doe",
        givenName = "John",
        middleName = None,
        honorificPrefix = None,
        honorificSuffix = None
      ),
      photos = List(
        Photo("photo_123", "https://example.com/photo.jpg", "profile")
      ),
      phoneNumbers = List.empty,
      addresses = List.empty,
      emails = List(
        Email("email_123", "john@example.com", Some("work"))
      ),
      verifications = List(
        Verification(
          id = "verification_123",
          email = "john@example.com",
          verified = true,
          createdAt = "2023-01-01T00:00:00Z",
          updatedAt = "2023-01-02T00:00:00Z"
        )
      ),
      provider = "authdog",
      createdAt = "2023-01-01T00:00:00Z",
      updatedAt = "2023-01-02T00:00:00Z",
      environmentId = "env_123"
    )
    val json = user.asJson.noSpaces
    
    json should include(""""id":"user_123"""")
    json should include(""""displayName":"John Doe"""")
    json should include(""""provider":"authdog"""")
  }
  
  "UserInfoResponse" should "be decoded from JSON" in {
    val json = """{
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
    }"""
    val result = decode[UserInfoResponse](json)
    
    result shouldBe a[Right[_, _]]
    val response = result.right.get
    response.meta.code shouldBe 200
    response.meta.message shouldBe "Success"
    response.session.remainingSeconds shouldBe 3600
    response.user.id shouldBe "user_123"
    response.user.displayName shouldBe "John Doe"
  }
  
  it should "be encoded to JSON" in {
    val response = UserInfoResponse(
      meta = Meta(200, "Success"),
      session = Session(3600),
      user = User(
        id = "user_123",
        externalId = "ext_123",
        userName = "johndoe",
        displayName = "John Doe",
        nickName = None,
        profileUrl = None,
        title = None,
        userType = None,
        preferredLanguage = None,
        locale = "en_US",
        timezone = None,
        active = true,
        names = Names(
          id = "name_123",
          formatted = Some("John Doe"),
          familyName = "Doe",
          givenName = "John",
          middleName = None,
          honorificPrefix = None,
          honorificSuffix = None
        ),
        photos = List.empty,
        phoneNumbers = List.empty,
        addresses = List.empty,
        emails = List(
          Email("email_123", "john@example.com", Some("work"))
        ),
        verifications = List.empty,
        provider = "authdog",
        createdAt = "2023-01-01T00:00:00Z",
        updatedAt = "2023-01-02T00:00:00Z",
        environmentId = "env_123"
      )
    )
    val json = response.asJson.noSpaces
    
    json should include(""""code":200""")
    json should include(""""remainingSeconds":3600""")
    json should include(""""id":"user_123"""")
  }
}
