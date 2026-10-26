import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart'
    show MyAccountException;

import 'js_interop.dart';
import 'js_interop_utils.dart';

/// The DPoP nonce key auth0-spa-js uses for My Account API requests.
const _myAccountDpopNonceId = '__auth0_my_account_api__';

class Auth0FlutterWebClientProxy {
  final Auth0Client client;

  /// The My Account API base URL, `https://{domain}/me/`.
  final String myAccountApiBase;

  /// Whether DPoP is enabled on [client], in which case My Account requests
  /// are sent with a DPoP proof.
  final bool useDPoP;

  Auth0FlutterWebClientProxy(
      {required this.client,
      required this.myAccountApiBase,
      this.useDPoP = false});

  Future<void> loginWithRedirect(final RedirectLoginOptions options) =>
      JSPromiseToFuture(client.loginWithRedirect(options)).toDart;

  Future<void> loginWithPopup(
          [final PopupLoginOptions? options,
          final PopupConfigOptions? config]) =>
      JSPromiseToFuture(client.loginWithPopup(options, config)).toDart;

  Future<void> checkSession() =>
      JSPromiseToFuture(client.checkSession()).toDart;

  Future<WebCredentials> getTokenSilently(
          [final GetTokenSilentlyOptions? options]) =>
      JSPromiseToFuture(client.getTokenSilently(options)).toDart;

  Future<WebCredentials> exchangeToken(final ExchangeTokenOptions options) =>
      JSPromiseToFuture(client.exchangeToken(options)).toDart;

  Future<RedirectLoginResult> handleRedirectCallback([final String? url]) {
    // Omit the url if it is not provided, so that the default argument is used.
    if (url == null) {
      return JSPromiseToFuture(client.handleRedirectCallback()).toDart;
    } else {
      return JSPromiseToFuture(client.handleRedirectCallback(url.toJS)).toDart;
    }
  }

  Future<bool> isAuthenticated() async {
    final jsBool = await JSPromiseToFuture(client.isAuthenticated()).toDart;
    return jsBool.toDart;
  }

  Future<void> logout(final LogoutOptions? options) =>
      JSPromiseToFuture(client.logout(options)).toDart;

  Future<JSArray<MfaAuthenticatorJS>> mfaGetAuthenticators(
          final String mfaToken) =>
      JSPromiseToFuture(client.mfa.getAuthenticators(mfaToken)).toDart;

  Future<MfaEnrollmentResponse> mfaEnroll(final MfaEnrollParams params) =>
      JSPromiseToFuture(client.mfa.enroll(params)).toDart;

  Future<MfaChallengeResponse> mfaChallenge(final MfaChallengeParams params) =>
      JSPromiseToFuture(client.mfa.challenge(params)).toDart;

  Future<WebCredentials> mfaVerify(final MfaVerifyParams params) =>
      JSPromiseToFuture(client.mfa.verify(params)).toDart;

  Future<PasskeyChallengeResponse> passkeyGetSignupChallenge(
          final PasskeySignupChallengeParams params) =>
      JSPromiseToFuture(client.passkey.getSignupChallenge(params)).toDart;

  Future<PasskeyChallengeResponse> passkeyGetLoginChallenge(
          [final PasskeyLoginChallengeParams? params]) =>
      JSPromiseToFuture(client.passkey.getLoginChallenge(params)).toDart;

  Future<WebCredentials> passkeyGetTokenWithPasskey(
          final PasskeyGetTokenParams params) =>
      JSPromiseToFuture(client.passkey.getTokenWithPasskey(params)).toDart;

  Future<JSArray<MyAccountAuthenticationMethodJS>>
      myAccountGetAuthenticationMethods(String accessToken, String? type) =>
          JSPromiseToFuture(
                  _myAccount(accessToken).getAuthenticationMethods(type))
              .toDart;

  Future<MyAccountAuthenticationMethodJS> myAccountGetAuthenticationMethod(
          String accessToken, String id) =>
      JSPromiseToFuture(_myAccount(accessToken).getAuthenticationMethod(id))
          .toDart;

  Future<void> myAccountDeleteAuthenticationMethod(
          String accessToken, String id) =>
      JSPromiseToFuture(_myAccount(accessToken).deleteAuthenticationMethod(id))
          .toDart;

  Future<MyAccountAuthenticationMethodJS> myAccountUpdateAuthenticationMethod(
          String accessToken,
          String id,
          MyAccountUpdateAuthenticationMethodParams params) =>
      JSPromiseToFuture(
              _myAccount(accessToken).updateAuthenticationMethod(id, params))
          .toDart;

  Future<JSArray<MyAccountFactorJS>> myAccountGetFactors(String accessToken) =>
      JSPromiseToFuture(_myAccount(accessToken).getFactors()).toDart;

  Future<MyAccountEnrollmentChallengeJS> myAccountEnrollmentChallenge(
          String accessToken, MyAccountEnrollmentChallengeParams params) =>
      JSPromiseToFuture(_myAccount(accessToken).enrollmentChallenge(params))
          .toDart;

  Future<MyAccountAuthenticationMethodJS> myAccountEnrollmentVerify(
          String accessToken, MyAccountEnrollmentVerifyParams params) =>
      JSPromiseToFuture(_myAccount(accessToken).enrollmentVerify(params))
          .toDart;

  // A new client is created per call because each call carries its own
  // access token, which the fetcher's `getAccessToken` closes over. This
  // avoids shared token state between concurrent calls. `createFetcher` does
  // no I/O, so the cost is negligible.
  MyAccountApiClient _myAccount(String accessToken) {
    // Without this check, older auth0-spa-js versions fail with a generic
    // "is not a constructor" TypeError, which would be indistinguishable from
    // a network failure.
    final auth0 = globalContext.getProperty<JSObject?>('auth0'.toJS);
    if (auth0 == null || !auth0.has('MyAccountApiClient')) {
      throw const MyAccountException.unknown(
          'The My Account API requires auth0-spa-js v2.21.1 or later.');
    }

    return MyAccountApiClient(
        client.createFetcher(JsInteropUtils.stripNulls(FetcherConfig(
            getAccessToken:
                ((JSAny? _) => Future.value(accessToken.toJS).toJS).toJS,
            baseUrl: myAccountApiBase,
            dpopNonceId: useDPoP ? _myAccountDpopNonceId : null))),
        myAccountApiBase);
  }
}
