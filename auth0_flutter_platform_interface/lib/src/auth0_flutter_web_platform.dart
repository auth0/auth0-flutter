import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import '../auth0_flutter_platform_interface.dart';

class StubAuth0FlutterWeb extends Auth0FlutterWebPlatform {
  StubAuth0FlutterWeb() : super();
}

abstract class Auth0FlutterWebPlatform extends PlatformInterface {
  Auth0FlutterWebPlatform() : super(token: _token);

  static Auth0FlutterWebPlatform get instance => _instance;
  static final Object _token = Object();
  static Auth0FlutterWebPlatform _instance = StubAuth0FlutterWeb();

  static set instance(final Auth0FlutterWebPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<Object?> get appState {
    throw UnimplementedError('web.appState has not been implemented');
  }

  Future<void> initialize(
    final ClientOptions clientOptions,
    final UserAgent userAgent,
  ) {
    throw UnimplementedError('web.initialize has not been implemented');
  }

  Future<void> loginWithRedirect(final LoginOptions? options) {
    throw UnimplementedError('web.loginWithRedirect has not been implemented');
  }

  Future<Credentials> loginWithPopup(final PopupLoginOptions? options) {
    throw UnimplementedError('web.loginWithPopup has not been implemented');
  }

  Future<Credentials> credentials(final CredentialsOptions? options) {
    throw UnimplementedError('web.credentials has not been implemented');
  }

  Future<Credentials> customTokenExchange(final ExchangeTokenOptions options) {
    throw UnimplementedError(
        'web.customTokenExchange has not been implemented'
    );
  }

  Future<ApiCredentials> getApiCredentials(
      final GetApiCredentialsOptions options) {
    throw UnimplementedError('web.getApiCredentials has not been implemented');
  }

  Future<void> clearApiCredentials(final ClearApiCredentialsOptions options) {
    throw UnimplementedError(
        'web.clearApiCredentials has not been implemented');
  }

  Future<bool> hasValidCredentials() {
    throw UnimplementedError(
      'web.hasValidCredentials has not been implemented',
    );
  }

  Future<void> logout(final LogoutOptions? options) {
    throw UnimplementedError('web.logout has not been implemented');
  }

  Future<List<MfaAuthenticator>> mfaGetAuthenticators(final String mfaToken) {
    throw UnimplementedError(
        'web.mfaGetAuthenticators has not been implemented');
  }

  Future<MfaEnrollmentChallenge> mfaEnrollTotp(final String mfaToken) {
    throw UnimplementedError('web.mfaEnrollTotp has not been implemented');
  }

  Future<MfaEnrollmentChallenge> mfaEnrollPhone(
    final String mfaToken,
    final String phoneNumber,
    final PhoneType type,
  ) {
    throw UnimplementedError('web.mfaEnrollPhone has not been implemented');
  }

  Future<MfaEnrollmentChallenge> mfaEnrollEmail(
    final String mfaToken,
    final String email,
  ) {
    throw UnimplementedError('web.mfaEnrollEmail has not been implemented');
  }

  Future<MfaEnrollmentChallenge> mfaEnrollPush(final String mfaToken) {
    throw UnimplementedError('web.mfaEnrollPush has not been implemented');
  }

  Future<MfaChallenge> mfaChallenge(
    final String mfaToken,
    final String authenticatorId,
  ) {
    throw UnimplementedError('web.mfaChallenge has not been implemented');
  }

  Future<Credentials> mfaVerify(
    final String mfaToken,
    final MfaVerifyOptions options,
  ) {
    throw UnimplementedError('web.mfaVerify has not been implemented');
  }
}
