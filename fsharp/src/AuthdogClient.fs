namespace Authdog

open System
open System.Net.Http
open System.Text.Json
open System.Threading.Tasks

[<CLIMutable>]
type AuthdogClientConfig =
    { BaseUrl: string
      ApiKey: string option
      TimeoutMs: int option
      HttpClient: HttpClient option }

module private Internal =
    let trimTrailingSlashes (s: string) = s.TrimEnd([|'/'|])

    let addDefaultHeaders (apiKey: string option) (req: HttpRequestMessage) =
        req.Headers.TryAddWithoutValidation("Content-Type", "application/json") |> ignore
        req.Headers.TryAddWithoutValidation("User-Agent", "authdog-fsharp-sdk/0.1.0") |> ignore
        match apiKey with
        | Some key when not (String.IsNullOrWhiteSpace key) ->
            req.Headers.Remove("Authorization") |> ignore
            req.Headers.TryAddWithoutValidation("Authorization", "Bearer " + key) |> ignore
        | _ -> ()

/// Minimal Authdog API client
[<Sealed>]
type AuthdogClient (config: AuthdogClientConfig) =
    let baseUrl = Internal.trimTrailingSlashes config.BaseUrl
    let apiKey = config.ApiKey
    let httpClient =
        match config.HttpClient with
        | Some c -> c
        | None ->
            let c = new HttpClient()
            c.Timeout <- TimeSpan.FromMilliseconds(float (defaultArg config.TimeoutMs 10000))
            c

    member _.GetUserInfo(accessToken: string) : Task<string> = task {
        let url = baseUrl + "/v1/userinfo"
        use req = new HttpRequestMessage(HttpMethod.Get, url)
        Internal.addDefaultHeaders apiKey req
        let authToUse =
            match apiKey with
            | Some key when not (String.IsNullOrWhiteSpace key) -> key
            | _ -> accessToken
        req.Headers.Remove("Authorization") |> ignore
        req.Headers.TryAddWithoutValidation("Authorization", "Bearer " + authToUse) |> ignore
        try
            use! resp = httpClient.SendAsync(req)
            let! body = resp.Content.ReadAsStringAsync()
            if resp.StatusCode = System.Net.HttpStatusCode.Unauthorized then
                return raise (AuthenticationException("Unauthorized - invalid or expired token"))
            elif int resp.StatusCode = 500 then
                try
                    use doc = JsonDocument.Parse(body)
                    let root = doc.RootElement
                    if root.TryGetProperty("error", ref (Unchecked.defaultof<JsonElement>)) then
                        let err = root.GetProperty("error").GetString()
                        match err with
                        | "GraphQL query failed" -> return raise (ApiException("GraphQL query failed"))
                        | "Failed to fetch user info" -> return raise (ApiException("Failed to fetch user info"))
                        | _ -> ()
                with _ -> ()
            if not resp.IsSuccessStatusCode then
                return raise (ApiException(sprintf "HTTP error %d: %s" (int resp.StatusCode) body))
            return body
        with
        | :? AuthenticationException as e -> return raise e
        | :? ApiException as e -> return raise e
        | e -> return raise (ApiException("Request failed: " + e.Message))
    }
