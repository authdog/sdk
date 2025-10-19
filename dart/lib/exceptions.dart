class AuthdogException implements Exception {
  final String message;
  const AuthdogException(this.message);

  @override
  String toString() => message;
}

class AuthenticationException extends AuthdogException {
  const AuthenticationException(String message) : super(message);
}

class ApiException extends AuthdogException {
  const ApiException(String message) : super(message);
}
