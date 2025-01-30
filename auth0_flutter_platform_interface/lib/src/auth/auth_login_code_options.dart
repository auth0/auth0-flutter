import '../request/request_options.dart';

class AuthLoginWithCodeOptions implements RequestOptions {
  final String verificationCode;
  final String? email;
  final String? phoneNumber;
  final String? scope;
  final String? audience;
  final Map<String, String> parameters;

  AuthLoginWithCodeOptions(
      {required this.verificationCode,
      this.email,
      this.phoneNumber,
      this.scope,
      this.audience,
      this.parameters = const {}});

  @override
  Map<String, dynamic> toMap() => {
        'email': email,
        'phoneNumber': phoneNumber,
        'verificationCode': verificationCode,
        'scope': scope,
        'audience': audience,
        'parameters': parameters
      };
}
