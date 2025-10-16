package com.authdog.types

import io.circe.generic.semiauto._
import io.circe.{Decoder, Encoder}

/**
 * User photo
 */
case class Photo(
  id: String,
  value: String,
  `type`: String
)

object Photo {
  implicit val decoder: Decoder[Photo] = deriveDecoder[Photo]
  implicit val encoder: Encoder[Photo] = deriveEncoder[Photo]
}
