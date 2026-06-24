import '../request/request_options.dart';

class MyAccountEnrollTotpOptions implements RequestOptions {
  final String accessToken;

  MyAccountEnrollTotpOptions({required this.accessToken});

  @override
  Map<String, dynamic> toMap() => {
        'accessToken': accessToken,
      };
}
