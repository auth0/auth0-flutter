import '../account.dart';
import 'request_options.dart';

abstract class BaseRequest<TOptions extends RequestOptions> {
  final TOptions options;
  final Account account;

  BaseRequest({
    required this.account,
    required this.options,
  });

  Map<String, dynamic> toMap() =>
      account.toMap()..addAll(options.toMap());
}

class ApiRequest<TOptions extends RequestOptions>
    extends BaseRequest<TOptions> {
  ApiRequest({
    required final Account account,
    required final TOptions options,
  }) : super(account: account, options: options);
}

class WebAuthRequest<TOptions extends RequestOptions>
    extends BaseRequest<TOptions> {
  WebAuthRequest({
    required final Account account,
    required final TOptions options,
  }) : super(account: account, options: options);
}
