import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';

class CredentialsManager {
  final Account _account;
  final UserAgent _userAgent;

  CredentialsManager(this._account, this._userAgent);

  Future<Credentials> getCredentials() => CredentialsManagerPlatform.instance
      .getCredentials(_createApiRequest(GetCredentialsOptions()));

  Future<void> saveCredentials(final Credentials credentials) =>
      CredentialsManagerPlatform.instance.saveCredentials(
          _createApiRequest(SaveCredentialsOptions(credentials: credentials)));

  Future<bool> hasValidCredentials() => CredentialsManagerPlatform.instance
      .hasValidCredentials(_createApiRequest(null));

  Future<void> clearCredentials() => CredentialsManagerPlatform.instance
      .clearCredentials(_createApiRequest(null));

  CredentialsManagerRequest<TOptions>
      _createApiRequest<TOptions extends RequestOptions>(
              final TOptions? options) =>
          CredentialsManagerRequest<TOptions>(
              account: _account, options: options, userAgent: _userAgent);
}
