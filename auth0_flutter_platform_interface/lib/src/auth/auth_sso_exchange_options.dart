import '../request/request_options.dart';

/// Options used to call `Auth0FlutterAuthPlatform.ssoExchange()`.
class AuthSSOExchangeOptions implements RequestOptions {
  final String refreshToken;
  final Map<String, String> parameters;
  final Map<String, String> headers;

  AuthSSOExchangeOptions({
    required this.refreshToken,
    this.parameters = const {},
    this.headers = const {},
  });

  @override
  Map<String, dynamic> toMap() => {
        'refreshToken': refreshToken,
        'parameters': parameters,
        'headers': headers,
      };
}
