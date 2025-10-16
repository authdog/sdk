package com.authdog.types

import io.circe.generic.semiauto._
import io.circe.{Decoder, Encoder}

/**
 * Session information
 */
case class Session(
  remainingSeconds: Int
)

object Session {
  implicit val decoder: Decoder[Session] = deriveDecoder[Session]
  implicit val encoder: Encoder[Session] = deriveEncoder[Session]
}
