import '../request/request_options.dart';

class MyAccountEnrollPushOptions implements RequestOptions {
  final String accessToken;

  MyAccountEnrollPushOptions({required this.accessToken});

  @override
  Map<String, dynamic> toMap() => {
        'accessToken': accessToken,
      };
}
