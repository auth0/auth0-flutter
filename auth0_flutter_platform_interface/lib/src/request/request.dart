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
  final LocalAuthentication? localAuthentication;
  final CredentialsManagerConfiguration? credentialsManagerConfiguration;
  final bool useDPoP;

  CredentialsManagerRequest({
    required final Account account,
    final TOptions? options,
    required final UserAgent userAgent,
    this.localAuthentication,
    this.credentialsManagerConfiguration,
    this.useDPoP = false,
  }) : super(account: account, options: options, userAgent: userAgent);

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['useDPoP'] = useDPoP;

    if (localAuthentication != null) {
      map.addAll({
        'localAuthentication': {
          'title': localAuthentication?.title,
          'description': localAuthentication?.description,
          'cancelTitle': localAuthentication?.cancelTitle,
          'fallbackTitle': localAuthentication?.fallbackTitle,
          'authenticationLevel': localAuthentication?.authenticationLevel?.index
        }
      });
    }

    if (credentialsManagerConfiguration != null) {
      map.addAll({
        'credentialsManagerConfiguration':
            credentialsManagerConfiguration?.toMap()
      });
    }

    return map;
  }
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
