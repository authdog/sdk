package com.authdog.types

import io.circe.generic.semiauto._
import io.circe.{Decoder, Encoder}

/**
 * User email
 */
case class Email(
  id: String,
  value: String,
  `type`: Option[String]
)

object Email {
  implicit val decoder: Decoder[Email] = deriveDecoder[Email]
  implicit val encoder: Encoder[Email] = deriveEncoder[Email]
}
