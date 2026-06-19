# Authdog Dart SDK

Minimal Dart client for Authdog.

## Usage

```dart
final client = AuthdogClient(AuthdogClientConfig(baseUrl: 'https://api.authdog.com'));
final info = await client.getUserInfo('access-token');
```
