import '../request/request_options.dart';

class MyAccountEnrollRecoveryCodeOptions implements RequestOptions {
  final String accessToken;

  MyAccountEnrollRecoveryCodeOptions({required this.accessToken});

  @override
  Map<String, dynamic> toMap() => {
        'accessToken': accessToken,
      };
}
