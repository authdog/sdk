#pragma once

#include <string>
#include <vector>
#include <optional>
#include <nlohmann/json.hpp>

namespace authdog {

// Custom serialization for std::optional<std::string>
namespace nlohmann {
    template<>
    struct adl_serializer<std::optional<std::string>> {
        static void to_json(json& j, const std::optional<std::string>& opt) {
            if (opt.has_value()) {
                j = opt.value();
            } else {
                j = nullptr;
            }
        }

        static void from_json(const json& j, std::optional<std::string>& opt) {
            if (j.is_null()) {
                opt = std::nullopt;
            } else {
                opt = j.get<std::string>();
            }
        }
    };
}

/**
 * Metadata in the response
 */
struct Meta {
    int code;
    std::string message;
    
    NLOHMANN_DEFINE_TYPE_INTRUSIVE(Meta, code, message)
};

/**
 * Session information
 */
struct Session {
    int remainingSeconds;
    
    NLOHMANN_DEFINE_TYPE_INTRUSIVE(Session, remainingSeconds)
};

/**
 * User name information
 */
struct Names {
    std::string id;
    std::optional<std::string> formatted;
    std::string familyName;
    std::string givenName;
    std::optional<std::string> middleName;
    std::optional<std::string> honorificPrefix;
    std::optional<std::string> honorificSuffix;
    
    NLOHMANN_DEFINE_TYPE_INTRUSIVE(Names, id, formatted, familyName, givenName, 
                                   middleName, honorificPrefix, honorificSuffix)
};

/**
 * User photo
 */
struct Photo {
    std::string id;
    std::string value;
    std::string type;
    
    NLOHMANN_DEFINE_TYPE_INTRUSIVE(Photo, id, value, type)
};

/**
 * User email
 */
struct Email {
    std::string id;
    std::string value;
    std::optional<std::string> type;
    
    NLOHMANN_DEFINE_TYPE_INTRUSIVE(Email, id, value, type)
};

/**
 * Email verification status
 */
struct Verification {
    std::string id;
    std::string email;
    bool verified;
    std::string createdAt;
    std::string updatedAt;
    
    NLOHMANN_DEFINE_TYPE_INTRUSIVE(Verification, id, email, verified, createdAt, updatedAt)
};

/**
 * User information
 */
struct User {
    std::string id;
    std::string externalId;
    std::string userName;
    std::string displayName;
    std::optional<std::string> nickName;
    std::optional<std::string> profileUrl;
    std::optional<std::string> title;
    std::optional<std::string> userType;
    std::optional<std::string> preferredLanguage;
    std::string locale;
    std::optional<std::string> timezone;
    bool active;
    Names names;
    std::vector<Photo> photos;
    std::vector<nlohmann::json> phoneNumbers;
    std::vector<nlohmann::json> addresses;
    std::vector<Email> emails;
    std::vector<Verification> verifications;
    std::string provider;
    std::string createdAt;
    std::string updatedAt;
    std::string environmentId;
    
    NLOHMANN_DEFINE_TYPE_INTRUSIVE(User, id, externalId, userName, displayName, nickName,
                                  profileUrl, title, userType, preferredLanguage, locale,
                                  timezone, active, names, photos, phoneNumbers, addresses,
                                  emails, verifications, provider, createdAt, updatedAt, environmentId)
};

/**
 * Response from the /v1/userinfo endpoint
 */
struct UserInfoResponse {
    Meta meta;
    Session session;
    User user;
    
    NLOHMANN_DEFINE_TYPE_INTRUSIVE(UserInfoResponse, meta, session, user)
};

} // namespace authdog
