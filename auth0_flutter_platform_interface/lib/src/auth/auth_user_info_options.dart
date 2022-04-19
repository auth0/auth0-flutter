import '../account.dart';
import '../telemetry.dart';

class AuthUserInfoOptions {
  String accessToken;
  Account account;
  Telemetry telemetry;

  AuthUserInfoOptions(
      {required final this.accessToken, required final this.account, required final this.telemetry});

  Map<String, dynamic> toMap() => {
        'domain': account.domain,
        'clientId': account.clientId,
        'telemetry': telemetry.toMap(),
        'accessToken': accessToken,
      };
}
