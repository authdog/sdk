package com.authdog.types

import io.circe.{Decoder, Encoder, HCursor, Json}
import io.circe.syntax._

/**
 * User email
 */
case class Email(
  id: String,
  value: String,
  `type`: Option[String]
)

object Email {
  implicit val decoder: Decoder[Email] = (c: HCursor) => for {
    id <- c.downField("id").as[String]
    value <- c.downField("value").as[String]
    `type` <- c.downField("type").as[Option[String]]
  } yield Email(id, value, `type`)
  
  implicit val encoder: Encoder[Email] = (email: Email) => Json.obj(
    "id" -> email.id.asJson,
    "value" -> email.value.asJson,
    "type" -> email.`type`.asJson
  )
}
