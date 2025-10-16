package com.authdog.types

import io.circe.generic.semiauto._
import io.circe.{Decoder, Encoder}

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
  implicit val decoder: Decoder[Names] = deriveDecoder[Names]
  implicit val encoder: Encoder[Names] = deriveEncoder[Names]
}
