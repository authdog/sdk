package com.authdog.sdk

import kotlinx.serialization.Serializable
import kotlinx.serialization.json.JsonObject
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter

/**
 * User information response from the /userinfo endpoint
 */
@Serializable
data class UserInfoResponse(
    val meta: Meta,
    val session: Session,
    val user: User
)

/**
 * Metadata in the response
 */
@Serializable
data class Meta(
    val code: Int,
    val message: String
)

/**
 * Session information
 */
@Serializable
data class Session(
    val remainingSeconds: Int
)

/**
 * User information
 */
@Serializable
data class User(
    val id: String,
    val externalId: String,
    val userName: String,
    val displayName: String,
    val nickName: String? = null,
    val profileUrl: String? = null,
    val title: String? = null,
    val userType: String? = null,
    val preferredLanguage: String? = null,
    val locale: String,
    val timezone: String? = null,
    val active: Boolean,
    val names: Names,
    val photos: List<Photo>,
    val phoneNumbers: List<kotlinx.serialization.json.JsonObject>,
    val addresses: List<kotlinx.serialization.json.JsonObject>,
    val emails: List<Email>,
    val verifications: List<Verification>,
    val provider: String,
    val createdAt: String,
    val updatedAt: String,
    val environmentId: String
)

/**
 * User name information
 */
@Serializable
data class Names(
    val id: String,
    val formatted: String? = null,
    val familyName: String,
    val givenName: String,
    val middleName: String? = null,
    val honorificPrefix: String? = null,
    val honorificSuffix: String? = null
)

/**
 * User photo
 */
@Serializable
data class Photo(
    val id: String,
    val value: String,
    val type: String
)

/**
 * User email
 */
@Serializable
data class Email(
    val id: String,
    val value: String,
    val type: String? = null
)

/**
 * Email verification status
 */
@Serializable
data class Verification(
    val id: String,
    val email: String,
    val verified: Boolean,
    val createdAt: String,
    val updatedAt: String
)
