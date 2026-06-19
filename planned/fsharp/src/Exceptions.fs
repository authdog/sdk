namespace Authdog

open System

[<Sealed>]
type AuthenticationException(message: string) =
    inherit Exception(message)

[<Sealed>]
type ApiException(message: string) =
    inherit Exception(message)
