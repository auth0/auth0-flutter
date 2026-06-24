import '../request/request_options.dart';

class MyAccountConfirmEnrollmentOptions implements RequestOptions {
  final String accessToken;
  final String id;
  final String authSession;
  final String factorType;

  MyAccountConfirmEnrollmentOptions({
    required this.accessToken,
    required this.id,
    required this.authSession,
    required this.factorType,
  });

  @override
  Map<String, dynamic> toMap() => {
        'accessToken': accessToken,
        'id': id,
        'authSession': authSession,
        'factorType': factorType,
      };
}
