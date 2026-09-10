# Quickstart: Existing Authdog SDKs

**Date**: 2026-09-10  
**Feature**: `001-userinfo-sdk`

These snippets match the shipped 0.1.0 clients. Replace the base URL
and token with your environment.

## Prerequisites

```bash
curl -fsSL https://moonrepo.dev/install/proto.sh | bash
curl -fsSL https://moonrepo.dev/install/moon.sh | bash
proto use
```

## Python

```python
from authdog import AuthdogClient, AuthenticationError, APIError

with AuthdogClient("https://api.authdog.com") as client:
    try:
        info = client.get_userinfo("your-access-token")
        print(info["user"]["displayName"])
    except AuthenticationError as exc:
        print(exc)
    except APIError as exc:
        print(exc)
```

## Node.js / TypeScript

```typescript
import { AuthdogClient, AuthenticationError, APIError } from '@authdog/node-sdk';

const client = new AuthdogClient({ baseUrl: 'https://api.authdog.com' });
try {
  const info = await client.getUserInfo('your-access-token');
  console.log(info.user.displayName);
} catch (error) {
  if (error instanceof AuthenticationError || error instanceof APIError) {
    console.error(error.message);
  }
} finally {
  client.close();
}
```

## Go

```go
client := authdog.NewClient(authdog.ClientConfig{BaseURL: "https://api.authdog.com"})
info, err := client.GetUserInfo(ctx, "your-access-token")
if err != nil {
    log.Fatal(err)
}
fmt.Println(info.User.DisplayName)
```

`APIKey` on the constructor is stored for future endpoints; userinfo
always sends the access-token argument.

## Rust

```rust
let client = AuthdogClient::new(AuthdogClientConfig {
    base_url: "https://api.authdog.com".into(),
    ..Default::default()
})?;
let info = client.get_user_info("your-access-token").await?;
println!("{}", info.user.display_name);
```

## Java

```java
try (AuthdogClient client = new AuthdogClient("https://api.authdog.com")) {
    UserInfoResponse info = client.getUserInfo("your-access-token");
    System.out.println(info.getUser().getDisplayName());
}
```

## C#

```csharp
using var client = new AuthdogClient("https://api.authdog.com");
var info = await client.GetUserInfoAsync("your-access-token");
Console.WriteLine(info.User.DisplayName);
```

## Verify a local SDK

```bash
moon run python:test
moon run node:test
moon run go:test
moon run rust:test
moon run java:test
moon run csharp:test
```
