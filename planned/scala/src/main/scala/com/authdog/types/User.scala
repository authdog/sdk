package com.authdog.types

import io.circe.{Decoder, Encoder, HCursor, Json}
import io.circe.syntax._

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
  implicit val decoder: Decoder[User] = (c: HCursor) => for {
    id <- c.downField("id").as[String]
    externalId <- c.downField("externalId").as[String]
    userName <- c.downField("userName").as[String]
    displayName <- c.downField("displayName").as[String]
    nickName <- c.downField("nickName").as[Option[String]]
    profileUrl <- c.downField("profileUrl").as[Option[String]]
    title <- c.downField("title").as[Option[String]]
    userType <- c.downField("userType").as[Option[String]]
    preferredLanguage <- c.downField("preferredLanguage").as[Option[String]]
    locale <- c.downField("locale").as[String]
    timezone <- c.downField("timezone").as[Option[String]]
    active <- c.downField("active").as[Boolean]
    names <- c.downField("names").as[Names]
    photos <- c.downField("photos").as[List[Photo]]
    phoneNumbers <- c.downField("phoneNumbers").as[List[Json]]
    addresses <- c.downField("addresses").as[List[Json]]
    emails <- c.downField("emails").as[List[Email]]
    verifications <- c.downField("verifications").as[List[Verification]]
    provider <- c.downField("provider").as[String]
    createdAt <- c.downField("createdAt").as[String]
    updatedAt <- c.downField("updatedAt").as[String]
    environmentId <- c.downField("environmentId").as[String]
  } yield User(id, externalId, userName, displayName, nickName, profileUrl, title, userType, preferredLanguage, locale, timezone, active, names, photos, phoneNumbers, addresses, emails, verifications, provider, createdAt, updatedAt, environmentId)
  
  implicit val encoder: Encoder[User] = (user: User) => Json.obj(
    "id" -> user.id.asJson,
    "externalId" -> user.externalId.asJson,
    "userName" -> user.userName.asJson,
    "displayName" -> user.displayName.asJson,
    "nickName" -> user.nickName.asJson,
    "profileUrl" -> user.profileUrl.asJson,
    "title" -> user.title.asJson,
    "userType" -> user.userType.asJson,
    "preferredLanguage" -> user.preferredLanguage.asJson,
    "locale" -> user.locale.asJson,
    "timezone" -> user.timezone.asJson,
    "active" -> user.active.asJson,
    "names" -> user.names.asJson,
    "photos" -> user.photos.asJson,
    "phoneNumbers" -> user.phoneNumbers.asJson,
    "addresses" -> user.addresses.asJson,
    "emails" -> user.emails.asJson,
    "verifications" -> user.verifications.asJson,
    "provider" -> user.provider.asJson,
    "createdAt" -> user.createdAt.asJson,
    "updatedAt" -> user.updatedAt.asJson,
    "environmentId" -> user.environmentId.asJson
  )
}
