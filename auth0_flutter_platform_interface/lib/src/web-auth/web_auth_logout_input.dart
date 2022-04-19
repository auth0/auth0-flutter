import '../account.dart';
import '../telemetry.dart';

class WebAuthLogoutInput {
  final Account account;
  final Telemetry telemetry;
  final String? returnTo;
  final String? scheme;

  WebAuthLogoutInput({required this.account, required this.telemetry, this.returnTo, this.scheme});

  Map<String, dynamic> toMap() => {
        'domain': account.domain,
        'clientId': account.clientId,
        'telemetry': telemetry.toMap(),
        'returnTo': returnTo,
        'scheme': scheme
      };
}
