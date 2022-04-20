import '../account.dart';
import '../telemetry.dart';
import 'request_options.dart';

abstract class BaseRequest<TOptions extends RequestOptions> {
  final TOptions options;
  final Account account;
  final Telemetry telemetry;

  BaseRequest({
    required this.account,
    required this.options,
    required this.telemetry,
  });

  Map<String, dynamic> toMap() => account.toMap()
    ..addAll(options.toMap())
    ..addAll({'telemetry': telemetry.toMap()});
}

class ApiRequest<TOptions extends RequestOptions>
    extends BaseRequest<TOptions> {
  ApiRequest({
    required final Account account,
    required final TOptions options,
    required final Telemetry telemetry,
  }) : super(account: account, options: options, telemetry: telemetry);
}

class WebAuthRequest<TOptions extends RequestOptions>
    extends BaseRequest<TOptions> {
  WebAuthRequest({
    required final Account account,
    required final TOptions options,
    required final Telemetry telemetry,
  }) : super(account: account, options: options, telemetry: telemetry);
}
