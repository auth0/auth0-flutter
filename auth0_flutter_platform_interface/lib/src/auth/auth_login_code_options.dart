import '../request/request_options.dart';

class AuthLoginWithCodeOptions implements RequestOptions {
  final String verificationCode;
  final String? email;
  final String? phoneNumber;
  final Set<String> scopes;
  final String? audience;
  final Map<String, String> parameters;

  AuthLoginWithCodeOptions(
      {required this.verificationCode,
      this.email,
      this.phoneNumber,
      this.scopes = const {},
      this.audience,
      this.parameters = const {}});

  @override
  Map<String, dynamic> toMap() => {
        'email': email,
        'phoneNumber': phoneNumber,
        'verificationCode': verificationCode,
        'scopes': scopes.toList(),
        'audience': audience,
        'parameters': parameters
      };
}
