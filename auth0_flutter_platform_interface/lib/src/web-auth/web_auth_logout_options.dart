import '../request/request_options.dart';

class WebAuthLogoutOptions implements RequestOptions {
  final bool useHTTPS;
  final String? returnTo;
  final String? scheme;
  final Map<String, dynamic>? parameters;

  WebAuthLogoutOptions({
    this.useHTTPS = false,
    this.returnTo,
    this.scheme,
    this.parameters,
  });

  @override
  Map<String, dynamic> toMap() => {
    'useHTTPS': useHTTPS,
    'returnTo': returnTo,
    'scheme': scheme,
    'parameters': parameters,
  };
}
