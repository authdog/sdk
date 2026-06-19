package com.authdog.types

import io.circe.{Decoder, Encoder, HCursor, Json}
import io.circe.syntax._

/**
 * Session information
 */
case class Session(
  remainingSeconds: Int
)

object Session {
  implicit val decoder: Decoder[Session] = (c: HCursor) => for {
    remainingSeconds <- c.downField("remainingSeconds").as[Int]
  } yield Session(remainingSeconds)
  
  implicit val encoder: Encoder[Session] = (session: Session) => Json.obj(
    "remainingSeconds" -> session.remainingSeconds.asJson
  )
}
