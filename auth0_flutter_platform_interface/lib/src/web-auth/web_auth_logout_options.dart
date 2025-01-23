import '../request/request_options.dart';

class WebAuthLogoutOptions implements RequestOptions {
  final bool useHTTPS;
  final String? returnTo;
  final String? scheme;

  WebAuthLogoutOptions({this.useHTTPS = false, this.returnTo, this.scheme});

  @override
  Map<String, dynamic> toMap() =>
      {'useHTTPS': useHTTPS, 'returnTo': returnTo, 'scheme': scheme};
}
