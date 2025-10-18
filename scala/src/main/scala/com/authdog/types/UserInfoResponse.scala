package com.authdog.types

import io.circe.{Decoder, Encoder, HCursor, Json}
import io.circe.syntax._

/**
 * Response from the /v1/userinfo endpoint
 */
case class UserInfoResponse(
  meta: Meta,
  session: Session,
  user: User
)

object UserInfoResponse {
  implicit val decoder: Decoder[UserInfoResponse] = (c: HCursor) => for {
    meta <- c.downField("meta").as[Meta]
    session <- c.downField("session").as[Session]
    user <- c.downField("user").as[User]
  } yield UserInfoResponse(meta, session, user)
  
  implicit val encoder: Encoder[UserInfoResponse] = (response: UserInfoResponse) => Json.obj(
    "meta" -> response.meta.asJson,
    "session" -> response.session.asJson,
    "user" -> response.user.asJson
  )
}
