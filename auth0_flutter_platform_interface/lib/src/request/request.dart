import '../account.dart';
import 'request_options.dart';

abstract class BaseRequest<TOptions extends RequestOptions> {
  late TOptions? options;
  late Account account;

  BaseRequest({
    required this.account,
    this.options,
  });

  Map<String, dynamic> toMap() =>
      account.toMap()..addAll(options?.toMap() ?? {});
}

class ApiRequest<TOptions extends RequestOptions>
    extends BaseRequest<TOptions> {
  ApiRequest({
    required final Account account,
    final TOptions? options,
  }) : super(account: account, options: options);
}

class WebAuthRequest<TOptions extends RequestOptions>
    extends BaseRequest<TOptions> {
  WebAuthRequest({
    required final Account account,
    final TOptions? options,
  }) : super(account: account, options: options);
}
