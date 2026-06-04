import '../request/request_options.dart';

class MyAccountVerifyOtpOptions implements RequestOptions {
  final String accessToken;
  final String id;
  final String authSession;
  final String otp;
  final String factorType;

  MyAccountVerifyOtpOptions({
    required this.accessToken,
    required this.id,
    required this.authSession,
    required this.otp,
    required this.factorType,
  });

  @override
  Map<String, dynamic> toMap() => {
        'accessToken': accessToken,
        'id': id,
        'authSession': authSession,
        'otp': otp,
        'factorType': factorType,
      };
}
