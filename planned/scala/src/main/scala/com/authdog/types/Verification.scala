package com.authdog.types

import io.circe.{Decoder, Encoder, HCursor, Json}
import io.circe.syntax._

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
  implicit val decoder: Decoder[Verification] = (c: HCursor) => for {
    id <- c.downField("id").as[String]
    email <- c.downField("email").as[String]
    verified <- c.downField("verified").as[Boolean]
    createdAt <- c.downField("createdAt").as[String]
    updatedAt <- c.downField("updatedAt").as[String]
  } yield Verification(id, email, verified, createdAt, updatedAt)
  
  implicit val encoder: Encoder[Verification] = (verification: Verification) => Json.obj(
    "id" -> verification.id.asJson,
    "email" -> verification.email.asJson,
    "verified" -> verification.verified.asJson,
    "createdAt" -> verification.createdAt.asJson,
    "updatedAt" -> verification.updatedAt.asJson
  )
}
