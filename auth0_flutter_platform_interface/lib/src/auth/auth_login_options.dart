import '../account.dart';
import '../telemetry.dart';

class AuthLoginOptions {
  final Account account;
  final Telemetry telemetry;
  final String usernameOrEmail;
  final String password;
  final String connectionOrRealm;
  final Set<String> scopes;
  final Map<String, String> parameters;

  AuthLoginOptions(
      {required this.account,
      required this.telemetry,
      required this.usernameOrEmail,
      required this.password,
      required this.connectionOrRealm,
      this.scopes = const {},
      this.parameters = const {}});

      Map<String, dynamic> toMap() => {
        'domain': account.domain,
        'clientId': account.clientId,
        'telemetry': telemetry.toMap(),
        'usernameOrEmail': usernameOrEmail,
        'password': password,
        'connectionOrRealm': connectionOrRealm,
        'scopes': scopes.toList(),
        'parameters': parameters
      };
}
