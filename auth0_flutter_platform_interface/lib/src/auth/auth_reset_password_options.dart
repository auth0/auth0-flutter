import '../account.dart';
import '../telemetry.dart';

import '../request/request_options.dart';

class AuthResetPasswordOptions implements RequestOptions {
  final Telemetry telemetry;
  final String email;
  final String connection;
  final Map<String, String> parameters;

  AuthResetPasswordOptions({
    required this.telemetry,
    required this.email,
    required this.connection,
    this.parameters = const {},
  });

  @override
  Map<String, dynamic> toMap() => {
        'telemetry': telemetry.toMap(),
        'email': email,
        'connection': connection,
        'parameters': parameters
      };
}
