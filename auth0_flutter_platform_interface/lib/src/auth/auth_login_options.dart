import '../request/request_options.dart';
import '../telemetry.dart';

class AuthLoginOptions implements RequestOptions {
  final Telemetry telemetry;
  final String usernameOrEmail;
  final String password;
  final String connectionOrRealm;
  final Set<String> scopes;
  final Map<String, String> parameters;

  AuthLoginOptions(
      {required this.telemetry,
      required this.usernameOrEmail,
      required this.password,
      required this.connectionOrRealm,
      this.scopes = const {},
      this.parameters = const {}});

  @override
  Map<String, dynamic> toMap() => {
        'telemetry': telemetry.toMap(),
        'usernameOrEmail': usernameOrEmail,
        'password': password,
        'connectionOrRealm': connectionOrRealm,
        'scopes': scopes.toList(),
        'parameters': parameters
      };
}
