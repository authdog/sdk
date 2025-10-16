package com.authdog.types

import io.circe.generic.semiauto._
import io.circe.{Decoder, Encoder}

/**
 * User information
 */
case class User(
  id: String,
  externalId: String,
  userName: String,
  displayName: String,
  nickName: Option[String],
  profileUrl: Option[String],
  title: Option[String],
  userType: Option[String],
  preferredLanguage: Option[String],
  locale: String,
  timezone: Option[String],
  active: Boolean,
  names: Names,
  photos: List[Photo],
  phoneNumbers: List[io.circe.Json],
  addresses: List[io.circe.Json],
  emails: List[Email],
  verifications: List[Verification],
  provider: String,
  createdAt: String,
  updatedAt: String,
  environmentId: String
)

object User {
  implicit val decoder: Decoder[User] = deriveDecoder[User]
  implicit val encoder: Encoder[User] = deriveEncoder[User]
}
