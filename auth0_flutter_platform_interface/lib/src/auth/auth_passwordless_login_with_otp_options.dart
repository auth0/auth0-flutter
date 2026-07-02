import '../request/request_options.dart';

class AuthPasswordlessLoginWithOtpOptions implements RequestOptions {
  final String authSession;
  final String otp;
  final Set<String> scopes;
  final String? audience;

  AuthPasswordlessLoginWithOtpOptions({
    required this.authSession,
    required this.otp,
    this.scopes = const {},
    this.audience,
  });

  @override
  Map<String, dynamic> toMap() => {
        'authSession': authSession,
        'otp': otp,
        'scopes': scopes.toList(),
        'audience': audience,
      };
}
