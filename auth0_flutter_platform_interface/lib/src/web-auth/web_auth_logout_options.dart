import '../request/request_options.dart';

class WebAuthLogoutOptions implements RequestOptions {
  final String? returnTo;
  final String? scheme;

  WebAuthLogoutOptions({this.returnTo, this.scheme});

  @override
  Map<String, dynamic> toMap() => {'returnTo': returnTo, 'scheme': scheme};
}
