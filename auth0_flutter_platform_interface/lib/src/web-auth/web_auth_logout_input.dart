import '../request/request_options.dart';

class WebAuthLogoutInput implements RequestOptions {
  final String? returnTo;
  final String? scheme;

  WebAuthLogoutInput({this.returnTo, this.scheme});

  @override
  Map<String, dynamic> toMap() => {'returnTo': returnTo, 'scheme': scheme};
}
