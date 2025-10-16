package com.authdog.types

import io.circe.generic.semiauto._
import io.circe.{Decoder, Encoder}

/**
 * Email verification status
 */
case class Verification(
  id: String,
  email: String,
  verified: Boolean,
  createdAt: String,
  updatedAt: String
)

object Verification {
  implicit val decoder: Decoder[Verification] = deriveDecoder[Verification]
  implicit val encoder: Encoder[Verification] = deriveEncoder[Verification]
}
