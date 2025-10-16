package com.authdog.types

import io.circe.generic.semiauto._
import io.circe.{Decoder, Encoder}

/**
 * Metadata in the response
 */
case class Meta(
  code: Int,
  message: String
)

object Meta {
  implicit val decoder: Decoder[Meta] = deriveDecoder[Meta]
  implicit val encoder: Encoder[Meta] = deriveEncoder[Meta]
}
