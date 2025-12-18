import '../request/request_options.dart';

class AuthDPoPHeadersOptions implements RequestOptions {
  final String url;
  final String method;
  final String accessToken;
  final String tokenType;

  const AuthDPoPHeadersOptions({
    required this.url,
    required this.method,
    required this.accessToken,
    this.tokenType = 'Bearer',
  });

  @override
  Map<String, dynamic> toMap() => {
        'url': url,
        'method': method,
        'accessToken': accessToken,
        'tokenType': tokenType,
      };
}
