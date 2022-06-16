import 'package:flutter/services.dart';

import '../auth/api_exception.dart';
import '../credentials.dart';
import '../request/request.dart';
import '../request/request_options.dart';
import 'credentials_manager_exception.dart';
import 'credentials_manager_platform.dart';
import 'options/clear_credentials_options.dart';
import 'options/get_credentials_options.dart';
import 'options/has_valid_credentials_options.dart';
import 'options/save_credentials_options.dart';

const MethodChannel _channel = MethodChannel('auth0.com/auth0_flutter/credentials_manager');
const String credentialsManagerSaveCredentialsMethod = 'credentialsManager#saveCredentials';
const String credentialsManagerGetCredentialsMethod = 'credentialsManager#getCredentials';
const String credentialsManagerClearCredentialsMethod = 'credentialsManager#clearCredentials';
const String credentialsManagerHasValidCredentialsMethod = 'credentialsManager#hasValidCredentials';

class MethodChannelCredentialsManager extends CredentialsManagerPlatform {
  @override
  Future<Credentials> getCredentials(final ApiRequest<GetCredentialsOptions> request) async {
    final Map<String, dynamic> result =
        await invokeMapRequest(method: credentialsManagerGetCredentialsMethod, request: request);

    return Credentials.fromMap(result);
  }

  @override
  Future<void> saveCredentials(final ApiRequest<SaveCredentialsOptions> request) async {
    await invokeMapRequest(method: credentialsManagerSaveCredentialsMethod, request: request, throwOnNull: false);
  }

  @override
  Future<void> clearCredentials(final ApiRequest<ClearCredentialsOptions> request) async {
    await invokeMapRequest(method: credentialsManagerClearCredentialsMethod, request: request, throwOnNull: false);
  }

  @override
  Future<bool> hasValidCredentials(final ApiRequest<HasValidCredentialsOptions> request) async {
    final bool? result =
        await invokeRequest<bool, HasValidCredentialsOptions>(method: credentialsManagerHasValidCredentialsMethod, request: request);

    return result ?? false;
  }

  Future<TResult?> invokeRequest<TResult, TOptions extends RequestOptions>({
    required final String method,
    required final ApiRequest<TOptions> request,
    final bool? throwOnNull = true,
  }) async {
    final TResult? result;
    try {
      result = await _channel.invokeMethod<TResult>(method, request.toMap());

    } on PlatformException catch (e) {
      throw ApiException.fromPlatformException(e);
    }

    if (result == null && throwOnNull == true) {
      throw const ApiException.unknown('Channel returned null.');
    }

    return result;
  }

  Future<Map<String, dynamic>> invokeMapRequest<TOptions extends RequestOptions>({
    required final String method,
    required final ApiRequest<TOptions> request,
    final bool? throwOnNull = true,
  }) async {
    final Map<String, dynamic>? result;
    try {
      result = await _channel.invokeMapMethod(method, request.toMap());
    } on PlatformException catch (e) {
      throw CredentialsManagerException.fromPlatformException(e);
    }

    if (result == null && throwOnNull == true) {
      throw const ApiException.unknown('Channel returned null.');
    }

    return result ?? {};
  }
}
