import 'dart:convert';
import 'package:http/http.dart' as http;

import 'exceptions.dart';
import 'types.dart';

class AuthdogClientConfig {
  final String baseUrl;
  final String? apiKey;
  final Duration timeout;
  final http.Client? httpClient;

  const AuthdogClientConfig({
    required this.baseUrl,
    this.apiKey,
    this.timeout = const Duration(seconds: 10),
    this.httpClient,
  });
}

class AuthdogClient {
  final String _baseUrl;
  final String? _apiKey;
  final http.Client _client;
  final Duration _timeout;

  AuthdogClient(AuthdogClientConfig config)
      : _baseUrl = config.baseUrl.replaceAll(RegExp(r"/+$$"), ''),
        _apiKey = config.apiKey,
        _timeout = config.timeout,
        _client = config.httpClient ?? http.Client();

  Map<String, String> _defaultHeaders() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'User-Agent': 'authdog-dart-sdk/0.1.0',
    };
    if (_apiKey != null && _apiKey!.isNotEmpty) {
      headers['Authorization'] = 'Bearer ' + _apiKey!;
    }
    return headers;
  }

  Future<UserInfoResponse> getUserInfo(String accessToken) async {
    final uri = Uri.parse(_baseUrl + '/v1/userinfo');
    final headers = Map<String, String>.from(_defaultHeaders());
    headers['Authorization'] = 'Bearer ' + accessToken;

    try {
      final response = await _client
          .get(uri, headers: headers)
          .timeout(_timeout);

      final status = response.statusCode;
      final body = response.body;

      if (status == 401) {
        throw AuthenticationException('Unauthorized - invalid or expired token');
      }

      if (status == 500) {
        try {
          final error = json.decode(body) as Map<String, dynamic>;
          final err = error['error'];
          if (err == 'GraphQL query failed') {
            throw ApiException('GraphQL query failed');
          } else if (err == 'Failed to fetch user info') {
            throw ApiException('Failed to fetch user info');
          }
        } catch (_) {}
      }

      if (status < 200 || status >= 300) {
        throw ApiException('HTTP error ' + status.toString() + ': ' + body);
      }

      final data = json.decode(body) as Map<String, dynamic>;
      return UserInfoResponse.fromJson(data);
    } on AuthdogException {
      rethrow;
    } on http.ClientException catch (e) {
      throw ApiException('Request failed: ' + e.toString());
    } on FormatException catch (e) {
      throw ApiException('Failed to parse response: ' + e.message);
    } catch (e) {
      throw ApiException('Request failed: ' + e.toString());
    }
  }

  void close() {
    _client.close();
  }
}
