module Authdog.Tests

open System
open System.Net
open System.Net.Http
open System.Threading
open System.Threading.Tasks
open Xunit
open Authdog

let toTask (t: Task<'T>) : Task =
    (t.ContinueWith(fun (_: Task<'T>) -> ()) :> Task)

type MockHandler(handler: HttpRequestMessage -> HttpResponseMessage) =
    inherit HttpMessageHandler()
    override _.SendAsync(request: HttpRequestMessage, cancellationToken: CancellationToken) =
        Task.FromResult(handler request)

[<Fact>]
let ``GetUserInfo success`` () = task {
    let body = "{\"meta\":{\"code\":200,\"message\":\"OK\"},\"session\":{\"remainingSeconds\":3600},\"user\":{\"id\":\"123\"}}"
    let handler = new MockHandler(fun _ ->
        let resp = new HttpResponseMessage(HttpStatusCode.OK)
        resp.Content <- new StringContent(body)
        resp)
    use client = new HttpClient(handler)
    let sdk = new AuthdogClient({ BaseUrl = "https://api.authdog.com"; ApiKey = None; TimeoutMs = Some 10000; HttpClient = Some client })
    let! result = sdk.GetUserInfo("token")
    Assert.Contains("\"id\":\"123\"", result)
}

[<Fact>]
let ``GetUserInfo unauthorized`` () = task {
    let handler = new MockHandler(fun _ -> new HttpResponseMessage(HttpStatusCode.Unauthorized))
    use client = new HttpClient(handler)
    let sdk = new AuthdogClient({ BaseUrl = "https://api.authdog.com"; ApiKey = None; TimeoutMs = Some 10000; HttpClient = Some client })
    let! ex = Assert.ThrowsAsync<AuthenticationException>(fun () -> toTask (sdk.GetUserInfo("bad")))
    Assert.Contains("Unauthorized", ex.Message)
}

[<Fact>]
let ``GetUserInfo GraphQL error`` () = task {
    let body = "{\"error\":\"GraphQL query failed\"}"
    let handler = new MockHandler(fun _ ->
        let resp = new HttpResponseMessage(HttpStatusCode.InternalServerError)
        resp.Content <- new StringContent(body)
        resp)
    use client = new HttpClient(handler)
    let sdk = new AuthdogClient({ BaseUrl = "https://api.authdog.com"; ApiKey = None; TimeoutMs = Some 10000; HttpClient = Some client })
    let! ex = Assert.ThrowsAsync<ApiException>(fun () -> toTask (sdk.GetUserInfo("t")))
    Assert.Contains("GraphQL query failed", ex.Message)
}

[<Fact>]
let ``GetUserInfo fetch error`` () = task {
    let body = "{\"error\":\"Failed to fetch user info\"}"
    let handler = new MockHandler(fun _ ->
        let resp = new HttpResponseMessage(HttpStatusCode.InternalServerError)
        resp.Content <- new StringContent(body)
        resp)
    use client = new HttpClient(handler)
    let sdk = new AuthdogClient({ BaseUrl = "https://api.authdog.com"; ApiKey = None; TimeoutMs = Some 10000; HttpClient = Some client })
    let! ex = Assert.ThrowsAsync<ApiException>(fun () -> toTask (sdk.GetUserInfo("t")))
    Assert.Contains("Failed to fetch user info", ex.Message)
}

[<Fact>]
let ``GetUserInfo other http error`` () = task {
    let handler = new MockHandler(fun _ ->
        let resp = new HttpResponseMessage(HttpStatusCode.BadRequest)
        resp.Content <- new StringContent("Bad")
        resp)
    use client = new HttpClient(handler)
    let sdk = new AuthdogClient({ BaseUrl = "https://api.authdog.com"; ApiKey = None; TimeoutMs = Some 10000; HttpClient = Some client })
    let! ex = Assert.ThrowsAsync<ApiException>(fun () -> toTask (sdk.GetUserInfo("t")))
    Assert.Contains("HTTP error 400", ex.Message)
}
