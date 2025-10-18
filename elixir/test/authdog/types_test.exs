defmodule Authdog.TypesTest do
  use ExUnit.Case
  alias Authdog.Types

  describe "Types.Meta" do
    test "from_map/1 creates Meta struct" do
      data = %{"code" => 200, "message" => "Success"}
      meta = Types.Meta.from_map(data)
      
      assert meta.code == 200
      assert meta.message == "Success"
    end
  end

  describe "Types.Session" do
    test "from_map/1 creates Session struct" do
      data = %{"remainingSeconds" => 3600}
      session = Types.Session.from_map(data)
      
      assert session.remaining_seconds == 3600
    end
  end

  describe "Types.Names" do
    test "from_map/1 creates Names struct" do
      data = %{
        "id" => "name_123",
        "formatted" => "John Doe",
        "familyName" => "Doe",
        "givenName" => "John",
        "middleName" => "William",
        "honorificPrefix" => "Mr.",
        "honorificSuffix" => "Jr."
      }
      
      names = Types.Names.from_map(data)
      
      assert names.id == "name_123"
      assert names.formatted == "John Doe"
      assert names.family_name == "Doe"
      assert names.given_name == "John"
      assert names.middle_name == "William"
      assert names.honorific_prefix == "Mr."
      assert names.honorific_suffix == "Jr."
    end
  end

  describe "Types.Photo" do
    test "from_map/1 creates Photo struct" do
      data = %{"id" => "photo_123", "value" => "https://example.com/photo.jpg", "type" => "profile"}
      photo = Types.Photo.from_map(data)
      
      assert photo.id == "photo_123"
      assert photo.value == "https://example.com/photo.jpg"
      assert photo.type == "profile"
    end
  end

  describe "Types.Email" do
    test "from_map/1 creates Email struct" do
      data = %{"id" => "email_123", "value" => "john@example.com", "type" => "work"}
      email = Types.Email.from_map(data)
      
      assert email.id == "email_123"
      assert email.value == "john@example.com"
      assert email.type == "work"
    end

    test "from_map/1 handles nil type" do
      data = %{"id" => "email_123", "value" => "john@example.com", "type" => nil}
      email = Types.Email.from_map(data)
      
      assert email.id == "email_123"
      assert email.value == "john@example.com"
      assert email.type == nil
    end
  end

  describe "Types.Verification" do
    test "from_map/1 creates Verification struct" do
      data = %{
        "id" => "verification_123",
        "email" => "john@example.com",
        "verified" => true,
        "createdAt" => "2023-01-01T00:00:00Z",
        "updatedAt" => "2023-01-02T00:00:00Z"
      }
      
      verification = Types.Verification.from_map(data)
      
      assert verification.id == "verification_123"
      assert verification.email == "john@example.com"
      assert verification.verified == true
      assert verification.created_at == "2023-01-01T00:00:00Z"
      assert verification.updated_at == "2023-01-02T00:00:00Z"
    end
  end

  describe "Types.User" do
    test "from_map/1 creates User struct" do
      data = %{
        "id" => "user_123",
        "externalId" => "ext_123",
        "userName" => "johndoe",
        "displayName" => "John Doe",
        "nickName" => "Johnny",
        "profileUrl" => "https://example.com/profile",
        "title" => "Software Engineer",
        "userType" => "employee",
        "preferredLanguage" => "en",
        "locale" => "en_US",
        "timezone" => "UTC",
        "active" => true,
        "names" => %{
          "id" => "name_123",
          "formatted" => "John Doe",
          "familyName" => "Doe",
          "givenName" => "John",
          "middleName" => nil,
          "honorificPrefix" => nil,
          "honorificSuffix" => nil
        },
        "photos" => [
          %{"id" => "photo_123", "value" => "https://example.com/photo.jpg", "type" => "profile"}
        ],
        "phoneNumbers" => [],
        "addresses" => [],
        "emails" => [
          %{"id" => "email_123", "value" => "john@example.com", "type" => "work"}
        ],
        "verifications" => [
          %{
            "id" => "verification_123",
            "email" => "john@example.com",
            "verified" => true,
            "createdAt" => "2023-01-01T00:00:00Z",
            "updatedAt" => "2023-01-02T00:00:00Z"
          }
        ],
        "provider" => "authdog",
        "createdAt" => "2023-01-01T00:00:00Z",
        "updatedAt" => "2023-01-02T00:00:00Z",
        "environmentId" => "env_123"
      }
      
      user = Types.User.from_map(data)
      
      assert user.id == "user_123"
      assert user.external_id == "ext_123"
      assert user.user_name == "johndoe"
      assert user.display_name == "John Doe"
      assert user.nick_name == "Johnny"
      assert user.profile_url == "https://example.com/profile"
      assert user.title == "Software Engineer"
      assert user.user_type == "employee"
      assert user.preferred_language == "en"
      assert user.locale == "en_US"
      assert user.timezone == "UTC"
      assert user.active == true
      assert user.provider == "authdog"
      assert user.created_at == "2023-01-01T00:00:00Z"
      assert user.updated_at == "2023-01-02T00:00:00Z"
      assert user.environment_id == "env_123"
      
      # Test nested structures
      assert %Types.Names{} = user.names
      assert user.names.given_name == "John"
      assert user.names.family_name == "Doe"
      
      assert length(user.photos) == 1
      assert %Types.Photo{} = hd(user.photos)
      assert hd(user.photos).value == "https://example.com/photo.jpg"
      
      assert length(user.emails) == 1
      assert %Types.Email{} = hd(user.emails)
      assert hd(user.emails).value == "john@example.com"
      
      assert length(user.verifications) == 1
      assert %Types.Verification{} = hd(user.verifications)
      assert hd(user.verifications).verified == true
    end
  end

  describe "Types.UserInfoResponse" do
    test "from_map/1 creates UserInfoResponse struct" do
      data = %{
        "meta" => %{"code" => 200, "message" => "Success"},
        "session" => %{"remainingSeconds" => 3600},
        "user" => %{
          "id" => "user_123",
          "externalId" => "ext_123",
          "userName" => "johndoe",
          "displayName" => "John Doe",
          "nickName" => nil,
          "profileUrl" => nil,
          "title" => nil,
          "userType" => nil,
          "preferredLanguage" => nil,
          "locale" => "en_US",
          "timezone" => nil,
          "active" => true,
          "names" => %{
            "id" => "name_123",
            "formatted" => "John Doe",
            "familyName" => "Doe",
            "givenName" => "John",
            "middleName" => nil,
            "honorificPrefix" => nil,
            "honorificSuffix" => nil
          },
          "photos" => [],
          "phoneNumbers" => [],
          "addresses" => [],
          "emails" => [
            %{"id" => "email_123", "value" => "john@example.com", "type" => "work"}
          ],
          "verifications" => [],
          "provider" => "authdog",
          "createdAt" => "2023-01-01T00:00:00Z",
          "updatedAt" => "2023-01-02T00:00:00Z",
          "environmentId" => "env_123"
        }
      }
      
      response = Types.UserInfoResponse.from_map(data)
      
      assert %Types.Meta{} = response.meta
      assert response.meta.code == 200
      assert response.meta.message == "Success"
      
      assert %Types.Session{} = response.session
      assert response.session.remaining_seconds == 3600
      
      assert %Types.User{} = response.user
      assert response.user.id == "user_123"
      assert response.user.display_name == "John Doe"
    end
  end
end
