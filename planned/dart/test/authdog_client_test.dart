import 'dart:convert';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

import 'package:authdog_sdk/authdog_client.dart';
import 'package:authdog_sdk/exceptions.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  setUpAll(() {
    registerFallbackValue(Uri.parse('https://example.com'));
    registerFallbackValue(http.Request('GET', Uri.parse('https://example.com')));
  });

  group('AuthdogClient', () {
    late MockHttpClient mockClient;
    late AuthdogClient client;

    setUp(() {
      mockClient = MockHttpClient();
      client = AuthdogClient(AuthdogClientConfig(
        baseUrl: 'https://api.authdog.com',
        httpClient: mockClient,
      ));
    });

    test('getUserInfo success', () async {
      final responseBody = json.encode({
        'meta': {'code': 200, 'message': 'OK'},
        'session': {'remainingSeconds': 3600},
        'user': {'id': '123', 'externalId': 'e', 'userName': 'u', 'displayName': 'd', 'nickName': null, 'profileUrl': null, 'title': null, 'userType': null, 'preferredLanguage': null, 'locale': 'en', 'timezone': null, 'active': true, 'names': {'id': 'n', 'formatted': 'd', 'familyName': 'ln', 'givenName': 'gn', 'middleName': null, 'honorificPrefix': null, 'honorificSuffix': null}, 'photos': [], 'phoneNumbers': [], 'addresses': [], 'emails': [], 'verifications': [], 'provider': 'p', 'createdAt': '2023-01-01T00:00:00Z', 'updatedAt': '2023-01-01T00:00:00Z', 'environmentId': 'env'}
      });

      when(() => mockClient.get(
            any(that: isA<Uri>()),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => http.Response(responseBody, 200, headers: {'content-type': 'application/json'}));

      final result = await client.getUserInfo('token');
      expect(result.user.id, equals('123'));
      expect(result.meta.code, equals(200));
    });

    test('getUserInfo 401 throws AuthenticationException', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('', 401));

      expect(() => client.getUserInfo('bad'), throwsA(isA<AuthenticationException>()));
    });

    test('getUserInfo 500 GraphQL error', () async {
      final body = json.encode({'error': 'GraphQL query failed'});
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(body, 500));

      expect(() => client.getUserInfo('t'), throwsA(predicate((e) => e is ApiException && e.toString().contains('GraphQL query failed'))));
    });

    test('getUserInfo 500 fetch error', () async {
      final body = json.encode({'error': 'Failed to fetch user info'});
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(body, 500));

      expect(() => client.getUserInfo('t'), throwsA(predicate((e) => e is ApiException && e.toString().contains('Failed to fetch user info'))));
    });

    test('getUserInfo non-2xx throws ApiException', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('Bad', 400));

      expect(() => client.getUserInfo('t'), throwsA(isA<ApiException>()));
    });

    test('close does not throw', () {
      expect(() => client.close(), returnsNormally);
    });
  });
}
