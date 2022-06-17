import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';

class CredentialsManager {
  final Account _account;
  final UserAgent _userAgent;

  CredentialsManager(this._account, this._userAgent);

  Future<Credentials> getCredentials({
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

  Future<void> saveCredentials(final Credentials credentials) =>
      CredentialsManagerPlatform.instance.saveCredentials(
          _createApiRequest(SaveCredentialsOptions(credentials: credentials)));

  Future<bool> hasValidCredentials({
    final int? minTtl,
  }) =>
      CredentialsManagerPlatform.instance.hasValidCredentials(
          _createApiRequest(HasValidCredentialsOptions(minTtl: minTtl)));

  Future<void> clearCredentials() => CredentialsManagerPlatform.instance
      .clearCredentials(_createApiRequest(null));

  CredentialsManagerRequest<TOptions>
      _createApiRequest<TOptions extends RequestOptions>(
              final TOptions? options) =>
          CredentialsManagerRequest<TOptions>(
              account: _account, options: options, userAgent: _userAgent);
}
