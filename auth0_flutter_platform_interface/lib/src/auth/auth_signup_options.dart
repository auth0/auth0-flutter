import '../request/request_options.dart';
import '../telemetry.dart';

class AuthSignupOptions implements RequestOptions {
  final Telemetry telemetry;

  final String email;
  final String? username;
  final String password;
  final String connection;
  final Map<String, String> userMetadata;

  AuthSignupOptions({
      required this.telemetry,
      required this.email,
      this.username,
      required this.password,
      required this.connection,
      this.userMetadata = const {}});

  @override
  Map<String, dynamic> toMap() => {
        'telemetry': telemetry.toMap(),
        'connection': connection,
        'username': username,
        'email': email,
        'password': password,
        'userMetadata': userMetadata
      };
}
