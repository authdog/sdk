package com.authdog.types

import io.circe.generic.semiauto._
import io.circe.{Decoder, Encoder}

/**
 * Response from the /v1/userinfo endpoint
 */
case class UserInfoResponse(
  meta: Meta,
  session: Session,
  user: User
)

object UserInfoResponse {
  implicit val decoder: Decoder[UserInfoResponse] = deriveDecoder[UserInfoResponse]
  implicit val encoder: Encoder[UserInfoResponse] = deriveEncoder[UserInfoResponse]
}
