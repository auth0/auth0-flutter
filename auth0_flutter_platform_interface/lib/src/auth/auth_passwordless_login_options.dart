import '../request/request_options.dart';
import 'auth_passwordless_type.dart';

class AuthPasswordlessLoginOptions implements RequestOptions {
  final String? email;
  final String? phoneNumber;
  final PasswordlessType passwordlessType;
  final Map<String, String> parameters;

  AuthPasswordlessLoginOptions(
      {required this.passwordlessType,
      this.email,
      this.phoneNumber,
      this.parameters = const {}});

  @override
  Map<String, dynamic> toMap() => {
        'email': email,
        'phoneNumber': phoneNumber,
        'passwordlessType': passwordlessType.name,
        'parameters': parameters
      };
}
