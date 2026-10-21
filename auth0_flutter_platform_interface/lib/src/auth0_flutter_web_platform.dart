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

  Future<WebPasskeyChallenge> passkeySignupChallenge(
    final WebPasskeySignupChallengeOptions options,
  ) {
    throw UnimplementedError(
        'web.passkeySignupChallenge has not been implemented');
  }

  Future<WebPasskeyChallenge> passkeyLoginChallenge(
    final WebPasskeyLoginChallengeOptions options,
  ) {
    throw UnimplementedError(
        'web.passkeyLoginChallenge has not been implemented');
  }

  Future<Credentials> getTokenByPasskey(
    final WebGetTokenByPasskeyOptions options,
  ) {
    throw UnimplementedError('web.getTokenByPasskey has not been implemented');
  }

  Future<List<AuthenticationMethod>> getAuthenticationMethods(
    final String accessToken,
    final AuthenticationMethodType? type,
  ) {
    throw UnimplementedError(
        'web.getAuthenticationMethods has not been implemented');
  }

  Future<AuthenticationMethod> getAuthenticationMethod(
    final String accessToken,
    final String id,
  ) {
    throw UnimplementedError(
        'web.getAuthenticationMethod has not been implemented');
  }

  Future<void> deleteAuthenticationMethod(
    final String accessToken,
    final String id,
  ) {
    throw UnimplementedError(
        'web.deleteAuthenticationMethod has not been implemented');
  }

  Future<AuthenticationMethod> updateAuthenticationMethod(
    final String accessToken,
    final String id,
    final String? name,
    final PhoneType? preferredAuthenticationMethod,
  ) {
    throw UnimplementedError(
        'web.updateAuthenticationMethod has not been implemented');
  }

  Future<List<Factor>> getFactors(final String accessToken) {
    throw UnimplementedError('web.getFactors has not been implemented');
  }

  Future<EnrollmentChallenge> enrollPhone(
    final String accessToken,
    final String phoneNumber,
    final PhoneType type,
  ) {
    throw UnimplementedError('web.enrollPhone has not been implemented');
  }

  Future<EnrollmentChallenge> enrollEmail(
    final String accessToken,
    final String email,
  ) {
    throw UnimplementedError('web.enrollEmail has not been implemented');
  }

  Future<EnrollmentChallenge> enrollTotp(final String accessToken) {
    throw UnimplementedError('web.enrollTotp has not been implemented');
  }

  Future<EnrollmentChallenge> enrollPush(final String accessToken) {
    throw UnimplementedError('web.enrollPush has not been implemented');
  }

  Future<EnrollmentChallenge> enrollRecoveryCode(final String accessToken) {
    throw UnimplementedError('web.enrollRecoveryCode has not been implemented');
  }

  Future<AuthenticationMethod> verifyOtp(
    final String accessToken,
    final String id,
    final String authSession,
    final String otp,
    final String factorType,
  ) {
    throw UnimplementedError('web.verifyOtp has not been implemented');
  }

  Future<PasskeyEnrollmentChallenge> enrollPasskeyChallenge(
    final String accessToken,
    final String? userIdentityId,
    final String? connection,
  ) {
    throw UnimplementedError(
        'web.enrollPasskeyChallenge has not been implemented');
  }

  Future<MyAccountPasskeyAuthenticationMethod> enrollPasskey(
    final String accessToken,
    final PasskeyEnrollmentChallenge challenge,
    final PasskeyCredential credential,
  ) {
    throw UnimplementedError('web.enrollPasskey has not been implemented');
  }

  Future<AuthenticationMethod> confirmEnrollment(
    final String accessToken,
    final String id,
    final String authSession,
    final String factorType,
  ) {
    throw UnimplementedError('web.confirmEnrollment has not been implemented');
  }
}
