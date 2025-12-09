// coverage:ignore-file
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'auth/auth_dpop_headers_options.dart';
import 'method_channel_auth0_flutter_dpop.dart';
import 'request/dpop_request.dart';
import 'request/request_options.dart';

/// Platform interface for DPoP (Demonstrating Proof-of-Possession) operations.
///
/// DPoP methods are decoupled from authentication API methods as they are
/// utility operations for generating cryptographic proofs, not authentication
/// operations themselves.
abstract class Auth0FlutterDPoPPlatform extends PlatformInterface {
  Auth0FlutterDPoPPlatform() : super(token: _token);

  static Auth0FlutterDPoPPlatform get instance => _instance;
  static final Object _token = Object();
  static Auth0FlutterDPoPPlatform _instance = MethodChannelAuth0FlutterDPoP();

  static set instance(final Auth0FlutterDPoPPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Generates DPoP (Demonstrating Proof-of-Possession) headers for making
  /// authenticated API requests.
  ///
  /// Returns a map containing the Authorization header and DPoP proof JWT.
  Future<Map<String, String>> getDPoPHeaders(
      final DPoPRequest<AuthDPoPHeadersOptions> request) {
    throw UnimplementedError('getDPoPHeaders() has not been implemented');
  }

  /// Clears the DPoP private key from secure storage.
  ///
  /// Should be called on logout to remove the DPoP cryptographic key.
  Future<void> clearDPoPKey(final DPoPRequest<RequestOptions> request) {
    throw UnimplementedError('clearDPoPKey() has not been implemented');
  }
}
