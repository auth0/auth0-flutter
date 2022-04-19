import '../account.dart';
import '../telemetry.dart';

class AuthResetPasswordOptions {
  final Account account;
  final Telemetry telemetry;
  final String email;
  final String connection;
  final Map<String, String> parameters;

  AuthResetPasswordOptions({
    required this.account,
    required this.telemetry,
    required this.email,
    required this.connection,
    this.parameters = const {},
  });

  Map<String, dynamic> toMap() => {
        'domain': account.domain,
        'clientId': account.clientId,
        'telemetry': telemetry.toMap(),
        'email': email,
        'connection': connection,
        'parameters': parameters
      };
}
