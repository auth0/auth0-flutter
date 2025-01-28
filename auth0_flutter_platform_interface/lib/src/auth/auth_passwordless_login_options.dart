import '../request/request_options.dart';
import 'auth_passwordless_type.dart';

class AuthPasswordlessLoginOptions implements RequestOptions {
  final String? email;
  final String? phoneNumber;
  final PasswordlessType? passwordlessType;
  final String? connection;
  final String? verificationCode;
  final String? scope;
  final String? audience;

  AuthPasswordlessLoginOptions(
      {this.email,
      this.phoneNumber,
      this.passwordlessType,
      this.connection,
      this.verificationCode,
      this.scope,
      this.audience});

  @override
  Map<String, dynamic> toMap() => {
        'email': email,
        'phoneNumber': phoneNumber,
        'passwordlessType': passwordlessType?.name,
        'connection': connection,
        'verificationCode': verificationCode,
        'scope': scope,
        'audience': audience
      };
}
