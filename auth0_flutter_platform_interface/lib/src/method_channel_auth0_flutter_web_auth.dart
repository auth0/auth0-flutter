import 'dart:async';

import 'package:flutter/services.dart';

import 'auth0_flutter_web_auth_platform.dart';
import 'credentials.dart';
import 'request/request.dart';
import 'request/request_options.dart';
import 'web-auth/web_auth_login_options.dart';
import 'web-auth/web_auth_logout_options.dart';
import 'web-auth/web_authentication_exception.dart';

const MethodChannel _channel =
    MethodChannel('auth0.com/auth0_flutter/web_auth');
const String loginMethod = 'webAuth#login';
const String logoutMethod = 'webAuth#logout';
const String cancelMethod = 'webAuth#cancel';

class MethodChannelAuth0FlutterWebAuth extends Auth0FlutterWebAuthPlatform {
  final StreamController<Credentials> _credentialsRecoveredController =
      StreamController<Credentials>.broadcast();

  MethodChannelAuth0FlutterWebAuth() {
    _channel.setMethodCallHandler(_handleNativeCallback);
    _channel.invokeMethod('webAuth#dartReady');
  }

  Future<dynamic> _handleNativeCallback(final MethodCall call) async {
    switch (call.method) {
      case 'webAuth#onLoginResult':
        final map = Map<String, dynamic>.from(call.arguments as Map);
        final credentials = Credentials.fromMap(map);
        _credentialsRecoveredController.add(credentials);
        break;
      case 'webAuth#onLoginError':
        break;
    }
  }

  @override
  Stream<Credentials> get onCredentialsRecovered =>
      _credentialsRecoveredController.stream;

  @override
  Future<Credentials> login(
      final WebAuthRequest<WebAuthLoginOptions> request) async {
    final Map<String, dynamic> result =
        await invokeRequest(method: loginMethod, request: request);

    return Credentials.fromMap(result);
  }

  @override
  Future<void> logout(
      final WebAuthRequest<WebAuthLogoutOptions> request) async {
    await invokeRequest(
      method: logoutMethod,
      request: request,
      throwOnNull: false,
    );
  }


  @override
  void cancel() {
    try {
      _channel.invokeMethod(cancelMethod);
    } on PlatformException catch (e) {
      throw WebAuthenticationException.fromPlatformException(e);
    }
  }

  Future<Map<String, dynamic>> invokeRequest<TOptions extends RequestOptions>({
    required final String method,
    required final WebAuthRequest<TOptions> request,
    final bool? throwOnNull = true,
  }) async {
    final Map<String, dynamic>? result;
    try {
      result = await _channel.invokeMapMethod(method, request.toMap());
    } on PlatformException catch (e) {
      throw WebAuthenticationException.fromPlatformException(e);
    }

    if (result == null && throwOnNull == true) {
      throw const WebAuthenticationException.unknown('Channel returned null.');
    }

    return result ?? {};
  }
}
