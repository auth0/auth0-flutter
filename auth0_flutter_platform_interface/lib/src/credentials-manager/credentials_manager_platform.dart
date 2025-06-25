// coverage:ignore-file
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../../auth0_flutter_platform_interface.dart';
import '../user_info.dart';
import '../credentials.dart';
import '../request/request.dart';
import 'method_channel_credentials_manager.dart';
import 'options/get_credentials_options.dart';
import 'options/has_valid_credentials_options.dart';
import 'options/save_credentials_options.dart';

/// The interface that implementations of CredentialsManager must implement.
abstract class CredentialsManagerPlatform extends PlatformInterface {
  CredentialsManagerPlatform() : super(token: _token);

  static CredentialsManagerPlatform get instance => _instance;

  static final Object _token = Object();

  /// The default instance of [CredentialsManagerPlatform] to use.
  ///
  /// Defaults to [MethodChannelCredentialsManager].
  static CredentialsManagerPlatform _instance =
      MethodChannelCredentialsManager();

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [CredentialsManagerPlatform] when they register
  /// themselves.
  static set instance(final CredentialsManagerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Retrieves the credentials from the native storage.
  Future<Credentials> getCredentials(
      final CredentialsManagerRequest<GetCredentialsOptions> request) {
    throw UnimplementedError('getCredentials() has not been implemented');
  }

  /// Retrieves the credentials from the native storage.
  Future<UserInfo> getIDTokenContents(final CredentialsManagerRequest request) {
    throw UnimplementedError('getIDTokenContents() has not been implemented');
  }

  /// Removes the credentials from the native storage if present.
  Future<bool> clearCredentials(final CredentialsManagerRequest request) {
    throw UnimplementedError('clearCredentials() has not been implemented');
  }

  /// Stores the given credentials in the native storage. Must have an
  /// access_token or id_token and a expires_in value.
  Future<bool> saveCredentials(
      final CredentialsManagerRequest<SaveCredentialsOptions> request) {
    throw UnimplementedError('saveCredentials() has not been implemented');
  }

  /// Checks if a non-expired pair of credentials can be obtained from the
  /// native storage.
  Future<bool> hasValidCredentials(
      final CredentialsManagerRequest<HasValidCredentialsOptions> request) {
    throw UnimplementedError('hasValidCredentials() has not been implemented');
  }
}
