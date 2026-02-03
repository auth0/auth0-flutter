import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';

/// Abstract CredentialsManager that can be used to provide a custom
/// CredentialManager.
abstract class CredentialsManager {
  Future<Credentials> credentials({
    final int minTtl = 0,
    final Set<String> scopes = const {},
    final Map<String, String> parameters = const {},
  });

  Future<Credentials> renewCredentials({
    final Map<String, String> parameters = const {},
  });

  Future<UserProfile?> user();

  Future<bool> storeCredentials(final Credentials credentials);

  Future<bool> hasValidCredentials({
    final int minTtl = 0,
  });

  Future<bool> clearCredentials();
}

/// Default [CredentialsManager] implementation that passes calls to
/// the Native CredentialManagers provided by Auth0.Android or Auth0.Swift,
/// depending on the platform.
class DefaultCredentialsManager extends CredentialsManager {
  final Account _account;
  final UserAgent _userAgent;
  final LocalAuthentication? _localAuthentication;
  final CredentialsManagerConfiguration? _credentialsManagerConfiguration;
  final bool _useDPoP;

  DefaultCredentialsManager(this._account, this._userAgent,
      {final LocalAuthentication? localAuthentication,
      final CredentialsManagerConfiguration? credentialsManagerConfiguration,
      final bool useDPoP = false})
      : _localAuthentication = localAuthentication,
        _credentialsManagerConfiguration = credentialsManagerConfiguration,
        _useDPoP = useDPoP;

  /// Retrieves the credentials from the storage and refreshes them if they have
  ///  already expired.
  ///
  /// Change the minimum time in seconds that the access token should last
  /// before expiration by setting the [minTtl].
  /// Use the [scopes] parameter to set the scope to request for the access
  /// token. If `null` is passed, the previous scope will be kept.
  /// Use the [parameters] parameter to send additional parameters in the
  /// request to refresh expired credentials.
  @override
  Future<Credentials> credentials({
    final int minTtl = 0,
    final Set<String> scopes = const {},
    final Map<String, String> parameters = const {},
  }) =>
      CredentialsManagerPlatform.instance
          .getCredentials(_createApiRequest(GetCredentialsOptions(
        minTtl: minTtl,
        scopes: scopes,
        parameters: parameters,
      )));

  /// Fetches new set of credentials each time and stores them in storage.
  /// This will replace the existing credentials currently stored
  /// even if they are not expired.
  ///
  /// Use the [parameters] parameter to send additional parameters in the
  /// request.
  @override
  Future<Credentials> renewCredentials({
    final Map<String, String> parameters = const {},
  }) =>
      CredentialsManagerPlatform.instance.renewCredentials(
          _createApiRequest(RenewCredentialsOptions(parameters: parameters)));

  /// Fetches the user profile associated with the stored credentials.
  /// Returns null if no credentials are present in storage.
  @override
  Future<UserProfile?> user() =>
      CredentialsManagerPlatform.instance.user(_createApiRequest(null));

  /// Stores the given credentials in the storage. Must have an `access_token`
  /// or `id_token` and a `expires_in` value.
  @override
  Future<bool> storeCredentials(final Credentials credentials) =>
      CredentialsManagerPlatform.instance.saveCredentials(
          _createApiRequest(SaveCredentialsOptions(credentials: credentials)));

  /// Checks if there is a valid `accessToken` available.
  /// If an `accessToken` is present, verifies whether it has expired or will
  /// expire within the given `minTtl`. On Android devices, if the token has
  /// expired and a refresh token is present, this returns true if the token
  /// can be renewed using the refresh token.
  ///
  /// Change the minimum time in seconds that the access token should last
  /// before expiration by setting the minTtl

  @override
  Future<bool> hasValidCredentials({
    final int minTtl = 0,
  }) =>
      CredentialsManagerPlatform.instance.hasValidCredentials(
          _createApiRequest(HasValidCredentialsOptions(minTtl: minTtl)));

  /// Removes the credentials from the storage if present.
  @override
  Future<bool> clearCredentials() => CredentialsManagerPlatform.instance
      .clearCredentials(_createApiRequest(null));

  CredentialsManagerRequest<TOptions>
      _createApiRequest<TOptions extends RequestOptions>(
              final TOptions? options) =>
          CredentialsManagerRequest<TOptions>(
              account: _account,
              options: options,
              userAgent: _userAgent,
              localAuthentication: _localAuthentication,
              credentialsManagerConfiguration: _credentialsManagerConfiguration,
              useDPoP: _useDPoP);
}
