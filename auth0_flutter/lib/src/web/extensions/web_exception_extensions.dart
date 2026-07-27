import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';

@JS('Object.keys')
external JSArray<JSString> keys(final JSObject o);

extension WebExceptionExtension on WebException {
  static WebException fromJsObject(final JSObject jsException) {
    final error = jsException.getProperty<JSString>('error'.toJS);
    final description =
        jsException.getProperty<JSString>('error_description'.toJS);
    final Map<String, JSAny?> details = {};

    keys(jsException).toDart.forEach((final JSString key) {
      if (key.toDart == 'error' || key.toDart == 'error_description') return;
      details[key.toDart] = jsException.getProperty<JSAny?>(key);
    });

    switch (error) {
      case 'invalid_request':
      case 'invalid_scope':
      case 'invalid_client':
      case 'requires_validation':
      case 'unauthorized_client':
      case 'access_denied':
      case 'invalid_grant':
      case 'endpoint_disabled':
      case 'method_not_allowed':
      case 'too_many_requests':
      case 'unsupported_response_type':
      case 'unsupported_grant_type':
      case 'temporarily_unavailable':
        return WebException.authenticationError(
            error.toDart, description.toDart, {'state': details['state']});
      case 'mfa_required':
        final mfaToken =
            (jsException.getProperty<JSString?>('mfa_token'.toJS) ??
                    jsException.getProperty<JSString?>('mfaToken'.toJS))
                ?.toDart ??
                '';
        return WebException.mfaError(description.toDart, mfaToken);
      case 'timeout':
        return WebException.timeout(description.toDart);
      case 'cancelled':
        return WebException.popupClosed(description.toDart);
      case 'missing_refresh_token':
        return WebException.missingRefreshToken(description.toDart);
    }

    return WebException(error.toDart, description.toDart, details);
  }

  /// Converts a passkey-related failure from `auth0-spa-js` into a
  /// [WebException].
  ///
  /// Two distinct error shapes can reach here:
  ///
  /// * `passkeySignupChallenge`/`passkeyLoginChallenge`, and the
  /// `passkey_invalid_credential` check in `getTokenByPasskey`, throw a
  /// `PasskeyError`-family object (`code`/`message`/optional `cause`).
  /// * `getTokenByPasskey`'s actual token exchange goes through
  /// `auth0-spa-js`'s internal `_requestTokenForPasskey`, which is not
  /// wrapped in a `PasskeyError` — it lets the token endpoint's
  /// `GenericError`/`MfaRequiredError`/`AuthenticationError` propagate as-is,
  /// carrying `error`/`error_description` (and, for `mfa_required`,
  /// `mfa_token`/`mfa_requirements`) instead of `code`/`message`. That shape
  /// is delegated to [fromJsObject] so it maps identically to how
  /// `credentials()`/`customTokenExchange()` already handle these same
  /// error codes (for example, `code == 'MFA_REQUIRED'` with `mfaToken` in
  /// `details`, usable directly with `Auth0Web.mfa(mfaToken:)`).
  static WebException fromPasskeyError(final JSObject jsException) {
    if (jsException.has('error')) {
      return fromJsObject(jsException);
    }

    final code = jsException.getProperty<JSString?>('code'.toJS);
    final message = jsException.getProperty<JSString?>('message'.toJS);

    return WebException.passkeyError(
        code?.toDart ?? 'passkey_error', message?.toDart ?? 'Unknown error');
  }
}
