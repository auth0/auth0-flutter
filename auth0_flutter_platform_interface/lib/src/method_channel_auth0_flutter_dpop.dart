// coverage:ignore-file
import 'package:flutter/services.dart';

import 'auth/api_exception.dart';
import 'auth/auth_dpop_headers_options.dart';
import 'auth0_flutter_dpop_platform.dart';
import 'request/dpop_request.dart';
import 'request/request_options.dart';

const String dpopGetHeadersMethod = 'dpop#getDPoPHeaders';
const String dpopClearKeyMethod = 'dpop#clearDPoPKey';

/// Method channel implementation of [Auth0FlutterDPoPPlatform].
class MethodChannelAuth0FlutterDPoP extends Auth0FlutterDPoPPlatform {
  final MethodChannel _channel =
      const MethodChannel('auth0.com/auth0_flutter/dpop');

  @override
  Future<Map<String, String>> getDPoPHeaders(
      final DPoPRequest<AuthDPoPHeadersOptions> request) async {
    final Map<String, dynamic> result =
        await _invokeRequest(method: dpopGetHeadersMethod, request: request);

    return result.cast<String, String>();
  }

  @override
  Future<void> clearDPoPKey(final DPoPRequest<RequestOptions> request) async {
    await _invokeRequest(
        method: dpopClearKeyMethod, request: request, throwOnNull: false);
  }

  Future<Map<String, dynamic>> _invokeRequest<TOptions extends RequestOptions>({
    required final String method,
    required final DPoPRequest<TOptions> request,
    final bool? throwOnNull = true,
  }) async {
    final Map<String, dynamic>? result;
    try {
      result = await _channel.invokeMapMethod(method, request.options.toMap());
    } on PlatformException catch (e) {
      throw ApiException.fromPlatformException(e);
    }

    if (result == null && throwOnNull == true) {
      throw const ApiException.unknown('Channel returned null.');
    }

    return result ?? {};
  }
}
