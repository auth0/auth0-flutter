import '../request/request_options.dart';

class MyAccountConfirmEnrollmentOptions implements RequestOptions {
  final String accessToken;
  final String id;
  final String authSession;

  MyAccountConfirmEnrollmentOptions({
    required this.accessToken,
    required this.id,
    required this.authSession,
  });

  @override
  Map<String, dynamic> toMap() => {
        'accessToken': accessToken,
        'id': id,
        'authSession': authSession,
      };
}
