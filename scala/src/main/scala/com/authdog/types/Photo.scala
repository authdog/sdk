package com.authdog.types

import io.circe.{Decoder, Encoder, HCursor, Json}
import io.circe.syntax._

/**
 * User photo
 */
case class Photo(
  id: String,
  value: String,
  `type`: String
)

object Photo {
  implicit val decoder: Decoder[Photo] = (c: HCursor) => for {
    id <- c.downField("id").as[String]
    value <- c.downField("value").as[String]
    `type` <- c.downField("type").as[String]
  } yield Photo(id, value, `type`)
  
  implicit val encoder: Encoder[Photo] = (photo: Photo) => Json.obj(
    "id" -> photo.id.asJson,
    "value" -> photo.value.asJson,
    "type" -> photo.`type`.asJson
  )
}
