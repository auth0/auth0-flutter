import '../request/request_options.dart';
import '../telemetry.dart';

class AuthUserInfoOptions implements RequestOptions {
  String accessToken;
  Telemetry telemetry;

  AuthUserInfoOptions(
      {required final this.accessToken, required final this.telemetry});

  @override
  Map<String, dynamic> toMap() => {
        'telemetry': telemetry.toMap(),
        'accessToken': accessToken,
      };
}
