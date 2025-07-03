import 'package:flutter/services.dart';

import '../../auth0_flutter_platform_interface.dart';
import '../request/request.dart';
import '../request/request_options.dart';
import 'credentials_manager_exception.dart';
import 'credentials_manager_platform.dart';
import 'options/get_credentials_options.dart';
import 'options/has_valid_credentials_options.dart';
import 'options/save_credentials_options.dart';

const MethodChannel _channel =
    MethodChannel('auth0.com/auth0_flutter/credentials_manager');
const String credentialsManagerSaveCredentialsMethod =
    'credentialsManager#saveCredentials';
const String credentialsManagerGetCredentialsMethod =
    'credentialsManager#getCredentials';
const String credentialsManagerGetUserProfileMethod =
'credentialsManager#getUserInfo';
const String credentialsManagerClearCredentialsMethod =
    'credentialsManager#clearCredentials';
const String credentialsManagerHasValidCredentialsMethod =
    'credentialsManager#hasValidCredentials';

/// Method Channel implementation to communicate with the Native
/// CredentialsManager
class MethodChannelCredentialsManager extends CredentialsManagerPlatform {
  /// Retrieves the credentials from the native storage and refresh them if
  /// they have already expired.
  ///
  /// Uses the [MethodChannel] to communicate with the Native platforms.
  @override
  Future<Credentials> getCredentials(
      final CredentialsManagerRequest<GetCredentialsOptions> request) async {
    final Map<String, dynamic> result = await _invokeMapRequest(
        method: credentialsManagerGetCredentialsMethod, request: request);

    return Credentials.fromMap(result);
  }

  /// Stores the given credentials in the native storage. Must have an
  /// access_token or id_token and a expires_in value.
  ///
  /// Uses the [MethodChannel] to communicate with the Native platforms.
  @override
  Future<bool> saveCredentials(
      final CredentialsManagerRequest<SaveCredentialsOptions> request) async {
    final bool? result = await _invokeRequest<bool, RequestOptions?>(
        method: credentialsManagerSaveCredentialsMethod, request: request);
    return result ?? true;
  }

  @override
  Future<UserInfo> getIDTokenContents(final CredentialsManagerRequest request) async {
      final Map<String, dynamic> result = await _invokeMapRequest(method: credentialsManagerGetUserProfileMethod, request: request);
      return UserInfo.fromJson(result);
  }

  /// Removes the credentials from the native storage if present.
  ///
  /// Uses the [MethodChannel] to communicate with the Native platforms.
  @override
  Future<bool> clearCredentials(final CredentialsManagerRequest request) async {
    final bool? result = await _invokeRequest<bool, RequestOptions?>(
        method: credentialsManagerClearCredentialsMethod, request: request);
    return result ?? true;
  }

  /// Checks if a non-expired pair of credentials can be obtained from the
  /// native storage.
  ///
  /// Uses the [MethodChannel] to communicate with the Native platforms.
  @override
  Future<bool> hasValidCredentials(
      final CredentialsManagerRequest<HasValidCredentialsOptions>
          request) async {
    final bool? result = await _invokeRequest(
        method: credentialsManagerHasValidCredentialsMethod, request: request);

    return result ?? false;
  }

  Future<TResult?> _invokeRequest<TResult, TOptions extends RequestOptions?>({
    required final String method,
    required final CredentialsManagerRequest<TOptions> request,
    final bool throwOnNull = true,
  }) async {
    final TResult? result;
    try {
      result = await _channel.invokeMethod<TResult>(method, request.toMap());
    } on PlatformException catch (e) {
      throw CredentialsManagerException.fromPlatformException(e);
    }

    if (result == null && throwOnNull == true) {
      throw const CredentialsManagerException.unknown('Channel returned null.');
    }

    return result;
  }

  Future<Map<String, dynamic>>
      _invokeMapRequest<TOptions extends RequestOptions?>({
    required final String method,
    required final CredentialsManagerRequest<TOptions> request,
    final bool throwOnNull = true,
  }) async {
    final Map<String, dynamic>? result;
    try {
      result = await _channel.invokeMapMethod(method, request.toMap());
    } on PlatformException catch (e) {
      throw CredentialsManagerException.fromPlatformException(e);
    }

    if (result == null && throwOnNull == true) {
      throw const CredentialsManagerException.unknown('Channel returned null.');
    }

    return result ?? {};
  }
}
