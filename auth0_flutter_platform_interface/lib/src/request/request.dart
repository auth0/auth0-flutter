import '../account.dart';
import '../user_agent.dart';
import 'request_options.dart';

abstract class BaseRequest<TOptions extends RequestOptions> {
  final TOptions? options;
  final Account account;
  final UserAgent userAgent;

  BaseRequest({
    required this.account,
    this.options,
    required this.userAgent,
  });

  Map<String, dynamic> toMap() => (options?.toMap() ?? {})
    ..addAll({'_account': account.toMap()})
    ..addAll({'_userAgent': userAgent.toMap()});
}

class CredentialsManagerRequest<TOptions extends RequestOptions>
    extends BaseRequest<TOptions> {
  CredentialsManagerRequest({
    required final Account account,
    final TOptions? options,
    required final UserAgent userAgent,
  }) : super(account: account, options: options, userAgent: userAgent);
}

class ApiRequest<TOptions extends RequestOptions>
    extends BaseRequest<TOptions> {
  ApiRequest({
    required final Account account,
    required final TOptions options,
    required final UserAgent userAgent,
  }) : super(account: account, options: options, userAgent: userAgent);
}

class WebAuthRequest<TOptions extends RequestOptions>
    extends BaseRequest<TOptions> {
  WebAuthRequest({
    required final Account account,
    required final TOptions options,
    required final UserAgent userAgent,
  }) : super(account: account, options: options, userAgent: userAgent);
}
