import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';

abstract class CredentialsManager {
Future<Credentials> get({
    final int? minTtl,
    final Set<String> scopes = const {},
    final Map<String, String>? parameters,
  });

  Future<void> set(final Credentials credentials);

  Future<bool> hasValidCredentials({
    final int? minTtl,
  });

  Future<void> clear();
}

class DefaultCredentialsManager extends CredentialsManager {
  final Account _account;
  final UserAgent _userAgent;

  DefaultCredentialsManager(this._account, this._userAgent);

  @override
  Future<Credentials> get({
    final int? minTtl,
    final Set<String> scopes = const {},
    final Map<String, String>? parameters,
  }) =>
      CredentialsManagerPlatform.instance
          .getCredentials(_createApiRequest(GetCredentialsOptions(
        minTtl: minTtl,
        scopes: scopes,
        parameters: parameters,
      )));

  @override
  Future<void> set(final Credentials credentials) =>
      CredentialsManagerPlatform.instance.saveCredentials(
          _createApiRequest(SaveCredentialsOptions(credentials: credentials)));

  @override
  Future<bool> hasValidCredentials({
    final int? minTtl,
  }) =>
      CredentialsManagerPlatform.instance.hasValidCredentials(
          _createApiRequest(HasValidCredentialsOptions(minTtl: minTtl)));

  @override
  Future<void> clear() => CredentialsManagerPlatform.instance
      .clearCredentials(_createApiRequest(null));

  CredentialsManagerRequest<TOptions>
      _createApiRequest<TOptions extends RequestOptions>(
              final TOptions? options) =>
          CredentialsManagerRequest<TOptions>(
              account: _account, options: options, userAgent: _userAgent);
}
