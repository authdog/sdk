package com.authdog.types

import io.circe.{Decoder, Encoder, HCursor, Json}
import io.circe.syntax._

/**
 * User name information
 */
case class Names(
  id: String,
  formatted: Option[String],
  familyName: String,
  givenName: String,
  middleName: Option[String],
  honorificPrefix: Option[String],
  honorificSuffix: Option[String]
)

object Names {
  implicit val decoder: Decoder[Names] = (c: HCursor) => for {
    id <- c.downField("id").as[String]
    formatted <- c.downField("formatted").as[Option[String]]
    familyName <- c.downField("familyName").as[String]
    givenName <- c.downField("givenName").as[String]
    middleName <- c.downField("middleName").as[Option[String]]
    honorificPrefix <- c.downField("honorificPrefix").as[Option[String]]
    honorificSuffix <- c.downField("honorificSuffix").as[Option[String]]
  } yield Names(id, formatted, familyName, givenName, middleName, honorificPrefix, honorificSuffix)
  
  implicit val encoder: Encoder[Names] = (names: Names) => Json.obj(
    "id" -> names.id.asJson,
    "formatted" -> names.formatted.asJson,
    "familyName" -> names.familyName.asJson,
    "givenName" -> names.givenName.asJson,
    "middleName" -> names.middleName.asJson,
    "honorificPrefix" -> names.honorificPrefix.asJson,
    "honorificSuffix" -> names.honorificSuffix.asJson
  )
}
