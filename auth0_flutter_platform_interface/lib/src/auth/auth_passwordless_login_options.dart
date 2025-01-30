import '../request/request_options.dart';
import 'auth_passwordless_type.dart';

class AuthPasswordlessLoginOptions implements RequestOptions {
  final String? email;
  final String? phoneNumber;
  final PasswordlessType passwordlessType;

  AuthPasswordlessLoginOptions({
    required this.passwordlessType,
    this.email,
    this.phoneNumber,
  });

  @override
  Map<String, dynamic> toMap() => {
        'email': email,
        'phoneNumber': phoneNumber,
        'passwordlessType': passwordlessType.name
      };
}
