package com.authdog.types

import io.circe.{Decoder, Encoder, HCursor, Json}
import io.circe.syntax._

/**
 * Metadata in the response
 */
case class Meta(
  code: Int,
  message: String
)

object Meta {
  implicit val decoder: Decoder[Meta] = (c: HCursor) => for {
    code <- c.downField("code").as[Int]
    message <- c.downField("message").as[String]
  } yield Meta(code, message)
  
  implicit val encoder: Encoder[Meta] = (meta: Meta) => Json.obj(
    "code" -> meta.code.asJson,
    "message" -> meta.message.asJson
  )
}
