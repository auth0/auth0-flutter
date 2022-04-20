import '../request/request_options.dart';
import '../telemetry.dart';

class WebAuthLogoutInput implements RequestOptions {
  final Telemetry telemetry;
  final String? returnTo;
  final String? scheme;

  WebAuthLogoutInput({required this.telemetry, this.returnTo, this.scheme});

  @override
  Map<String, dynamic> toMap() =>
      {'telemetry': telemetry.toMap(), 'returnTo': returnTo, 'scheme': scheme};
}
