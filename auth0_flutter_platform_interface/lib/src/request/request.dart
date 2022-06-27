import '../../auth0_flutter_platform_interface.dart';

abstract class BaseRequest<TOptions extends RequestOptions?> {
  final Account account;
  final TOptions options;
  final UserAgent userAgent;

  BaseRequest({
    required this.account,
    required this.options,
    required this.userAgent,
  });

  Map<String, dynamic> toMap() => (options?.toMap() ?? {})
    ..addAll({'_account': account.toMap()})
    ..addAll({'_userAgent': userAgent.toMap()});
}

class CredentialsManagerRequest<TOptions extends RequestOptions?>
    extends BaseRequest<TOptions?> {
  bool useBiometrics;
  CredentialsManagerRequest({
    required final Account account,
    final TOptions? options,
    required final UserAgent userAgent,
    final this.useBiometrics = false,
  }) : super(account: account, options: options, userAgent: userAgent);

  @override
  Map<String, dynamic> toMap() => (super.toMap())
    ..addAll({'useBiometrics': useBiometrics});
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
