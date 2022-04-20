import '../request/request_options.dart';
import '../telemetry.dart';

class AuthRenewAccessTokenOptions implements RequestOptions {
  final Telemetry telemetry;
  final String refreshToken;
  final Set<String> scopes;
  final Map<String, String> parameters;

  AuthRenewAccessTokenOptions({
    required this.telemetry,
    required this.refreshToken,
    this.scopes = const {},
    this.parameters = const {},
  });

  @override
  Map<String, dynamic> toMap() => {
        'telemetry': telemetry.toMap(),
        'refreshToken': refreshToken,
        'scopes': scopes.toList(),
        'parameters': parameters
      };
}
