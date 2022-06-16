import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';

class CredentialsManager {
  final Account _account;
  final UserAgent _userAgent;

  CredentialsManager(this._account, this._userAgent);

  Future<Credentials> getCredentials() {
    return CredentialsManagerPlatform.instance
        .getCredentials(_createApiRequest(GetCredentialsOptions()));
  }

  Future<void> saveCredentials(final Credentials credentials) {
    return CredentialsManagerPlatform.instance.saveCredentials(
        _createApiRequest(SaveCredentialsOptions(credentials: credentials)));
  }

  Future<bool> hasValidCredentials() {
    return CredentialsManagerPlatform.instance
        .hasValidCredentials(_createApiRequest(HasValidCredentialsOptions()));
  }

  Future<void> clearCredentials() {
    return CredentialsManagerPlatform.instance
        .clearCredentials(_createApiRequest(ClearCredentialsOptions()));
  }

  ApiRequest<TOptions> _createApiRequest<TOptions extends RequestOptions>(
          final TOptions options) =>
      ApiRequest<TOptions>(
          account: _account, options: options, userAgent: _userAgent);
}
