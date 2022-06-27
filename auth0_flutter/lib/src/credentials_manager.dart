import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';

/// Abstract CredentialsManager that can be used to provide a custom CredentialManager.
abstract class CredentialsManager {
  Future<Credentials> get({
    final int? minTtl,
    final Set<String> scopes = const {},
    final Map<String, String> parameters = const {},
  });

  Future<void> set(final Credentials credentials);

  Future<bool> hasValidCredentials({
    final int? minTtl,
  });

  Future<void> clear();
}

/// Default [CredentialsManager] implementation that passes calls to
/// the Native CredentialManagers provided by Auth0.Android or Auth0.Swift, depending on the platform.
class DefaultCredentialsManager extends CredentialsManager {
  final Account _account;
  final UserAgent _userAgent;
  late bool _useBiometrics;

  DefaultCredentialsManager(this._account, this._userAgent, {final bool useBiometrics = false}) {
    _useBiometrics = useBiometrics;
  }

  /// Retrieves the credentials from the storage and refreshes them if they have already expired.
  ///
  /// Change the minimum time in seconds that the access token should last before expiration by setting the [minTtl].
  /// Use the [scopes] parameter to set the scope to request for the access token. If `null` is passed, the previous scope will be kept.
  /// Use the [parameters] parameter to send additional parameters in the request to refresh expired credentials.
  @override
  Future<Credentials> get({
    final int? minTtl,
    final Set<String> scopes = const {},
    final Map<String, String> parameters = const {},
  }) =>
      CredentialsManagerPlatform.instance
          .getCredentials(_createApiRequest(GetCredentialsOptions(
        minTtl: minTtl,
        scopes: scopes,
        parameters: parameters,
      )));

  /// Stores the given credentials in the storage. Must have an `access_token` or `id_token` and a `expires_in` value.
  @override
  Future<void> set(final Credentials credentials) =>
      CredentialsManagerPlatform.instance.saveCredentials(
          _createApiRequest(SaveCredentialsOptions(credentials: credentials)));

  /// Checks if a non-expired pair of credentials can be obtained from this manager.
  ///
  /// Change the minimum time in seconds that the access token should last before expiration by setting the [minTtl].
  @override
  Future<bool> hasValidCredentials({
    final int? minTtl,
  }) =>
      CredentialsManagerPlatform.instance.hasValidCredentials(
          _createApiRequest(HasValidCredentialsOptions(minTtl: minTtl)));

  /// Removes the credentials from the storage if present.
  @override
  Future<void> clear() => CredentialsManagerPlatform.instance
      .clearCredentials(_createApiRequest(null));

  CredentialsManagerRequest<TOptions>
      _createApiRequest<TOptions extends RequestOptions>(
              final TOptions? options) =>
          CredentialsManagerRequest<TOptions>(
              account: _account, options: options, userAgent: _userAgent, useBiometrics: _useBiometrics);
}
