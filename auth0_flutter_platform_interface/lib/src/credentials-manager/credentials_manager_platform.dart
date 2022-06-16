// coverage:ignore-file
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../credentials.dart';
import '../request/request.dart';
import 'method_channel_credentials_manager.dart';
import 'options/clear_credentials_options.dart';
import 'options/get_credentials_options.dart';
import 'options/has_valid_credentials_options.dart';
import 'options/save_credentials_options.dart';

abstract class CredentialsManagerPlatform extends PlatformInterface {
  CredentialsManagerPlatform() : super(token: _token);

  static CredentialsManagerPlatform get instance => _instance;

  static final Object _token = Object();

  static CredentialsManagerPlatform _instance =
      MethodChannelCredentialsManager();

  static set instance(final CredentialsManagerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<Credentials> getCredentials(
      final ApiRequest<GetCredentialsOptions> request) {
    throw UnimplementedError('getCredentials() has not been implemented');
  }

  Future<void> clearCredentials(
      final ApiRequest<ClearCredentialsOptions> request) {
    throw UnimplementedError('clearCredentials() has not been implemented');
  }

  Future<void> saveCredentials(
      final ApiRequest<SaveCredentialsOptions> request) {
    throw UnimplementedError('saveCredentials() has not been implemented');
  }

  Future<bool> hasValidCredentials(
      final ApiRequest<HasValidCredentialsOptions> request) {
    throw UnimplementedError('hasValidCredentials() has not been implemented');
  }
}
