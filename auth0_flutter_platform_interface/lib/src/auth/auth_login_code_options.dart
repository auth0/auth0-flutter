import '../request/request_options.dart';

class AuthLoginWithCodeOptions implements RequestOptions {
  final String verificationCode;
  final String? email;
  final String? phoneNumber;
  final String? scope;
  final String? audience;

  AuthLoginWithCodeOptions(
      {required this.verificationCode,
      this.email,
      this.phoneNumber,
      this.scope,
      this.audience});

  @override
  Map<String, dynamic> toMap() => {
        'email': email,
        'phoneNumber': phoneNumber,
        'verificationCode': verificationCode,
        'scope': scope,
        'audience': audience
      };
}
