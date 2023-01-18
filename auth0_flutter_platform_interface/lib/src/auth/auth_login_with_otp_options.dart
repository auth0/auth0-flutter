import '../request/request_options.dart';

class AuthLoginWithOtpOptions implements RequestOptions {
  final String otp;
  final String mfaToken;

  AuthLoginWithOtpOptions({required this.otp, required this.mfaToken});

  @override
  Map<String, dynamic> toMap() => {'otp': otp, 'mfaToken': mfaToken};
}
