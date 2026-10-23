import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';

import '../js_interop.dart' as interop;
import '../js_interop_utils.dart';

/// Builds the My Account API base URL, `https://{domain}/me/`.
///
/// Mirrors how auth0-spa-js derives it: `https://` is only prepended when
/// [domain] does not already start with `http://` or `https://`.
String myAccountApiBaseFor(String domain) {
  final domainUrl =
      RegExp('^https?://').hasMatch(domain) ? domain : 'https://$domain';
  return '$domainUrl/me/';
}

/// Builds the URL of the authentication method identified by [id], which
/// auth0-spa-js expects as the `location` of an enrollment verification.
String myAccountAuthenticationMethodLocation(String apiBase, String id) =>
    '${apiBase}v1/authentication-methods/${Uri.encodeComponent(id)}';

DateTime? _parseDate(String? value) =>
    value != null ? DateTime.parse(value) : null;

List<String>? _toStringList(JSArray<JSString>? array) =>
    array?.toDart.map((e) => e.toDart).toList();

/// Maps a JS `AuthenticationMethod` from auth0-spa-js into the
/// platform-agnostic [AuthenticationMethod] model.
extension AuthenticationMethodWebExtension on AuthenticationMethod {
  static AuthenticationMethod fromWeb(
          interop.MyAccountAuthenticationMethodJS js) =>
      AuthenticationMethod(
        id: js.id,
        type: js.type,
        name: js.name,
        phoneNumber: js.phone_number,
        email: js.email,
        preferredAuthenticationMethod: js.preferred_authentication_method,
        createdAt: _parseDate(js.created_at),
        lastAuthAt: _parseDate(js.last_auth_at),
        confirmed: js.confirmed,
        usage: _toStringList(js.usage),
      );
}

/// Maps a JS `Factor` from auth0-spa-js into the platform-agnostic [Factor]
/// model.
extension FactorWebExtension on Factor {
  static Factor fromWeb(interop.MyAccountFactorJS js) =>
      Factor(type: js.type, usage: _toStringList(js.usage));
}

/// Maps a JS `EnrollmentChallengeResponse` from auth0-spa-js into
/// [EnrollmentChallenge], using the same field mapping as the Android and iOS
/// implementations.
extension EnrollmentChallengeWebExtension on EnrollmentChallenge {
  static EnrollmentChallenge fromWeb(
          interop.MyAccountEnrollmentChallengeJS js) =>
      EnrollmentChallenge(
        id: js.id,
        authSession: js.auth_session,
        totpSecret: js.manual_input_code,
        totpUri: js.barcode_uri,
        barcodeUri: js.barcode_uri,
        recoveryCode: js.recovery_code,
      );
}

/// Maps a passkey `EnrollmentChallengeResponse` from auth0-spa-js into
/// [PasskeyEnrollmentChallenge].
///
/// `authn_params_public_key` is passed through as the raw WebAuthn creation
/// options JSON, the same as on Android and iOS.
extension PasskeyEnrollmentChallengeWebExtension on PasskeyEnrollmentChallenge {
  static PasskeyEnrollmentChallenge fromWeb(
          interop.MyAccountEnrollmentChallengeJS js) =>
      PasskeyEnrollmentChallenge(
        authenticationMethodId: js.id,
        authSession: js.auth_session,
        authParamsPublicKey: Map<String, dynamic>.from(
            js.authn_params_public_key.dartify()! as Map<Object?, Object?>),
      );
}

/// Converts a passkey registration [PasskeyCredential] into the
/// `authn_response` that auth0-spa-js sends to verify a My Account passkey
/// enrollment.
///
/// Only the registration (attestation) fields of the authenticator response
/// are sent, because the My Account API rejects any others. The browser's
/// `credential.toJSON()` output also includes `authenticatorData`, which
/// [PasskeyCredential.fromMap] keeps because passkey login uses it. Unset
/// optional fields are omitted rather than sent as `null`.
extension PasskeyCredentialWebExtension on PasskeyCredential {
  JSObject toWebEnrollmentResponse() => JsInteropUtils.stripNulls({
        'id': id,
        'rawId': rawId,
        'type': type,
        'authenticatorAttachment': authenticatorAttachment,
        'response': {
          'clientDataJSON': response.clientDataJSON,
          if (response.attestationObject != null)
            'attestationObject': response.attestationObject,
        },
        'clientExtensionResults': clientExtensionResults,
      }.jsify()! as JSObject);
}

/// Maps the passkey authentication method returned by auth0-spa-js into
/// [MyAccountPasskeyAuthenticationMethod].
///
/// auth0-spa-js returns the raw My Account API JSON, so this reuses the same
/// [MyAccountPasskeyAuthenticationMethod.fromMap] mapping as mobile.
extension MyAccountPasskeyAuthenticationMethodWebExtension
    on MyAccountPasskeyAuthenticationMethod {
  static MyAccountPasskeyAuthenticationMethod fromWeb(JSObject js) =>
      MyAccountPasskeyAuthenticationMethod.fromMap(
          Map<String, dynamic>.from(js.dartify()! as Map<Object?, Object?>));
}

extension MyAccountExceptionWebExtension on MyAccountException {
  /// Converts a failure from the auth0-spa-js `MyAccountApiClient` into a
  /// [MyAccountException], populated the same way as on Android and iOS.
  ///
  /// * A `MyAccountApiError` (a non-2xx response from the My Account API)
  /// carries the API's `type`, `status`, `title`, `detail` and
  /// `validation_errors`.
  /// * A `TypeError` is what `fetch` throws when the request could not be sent
  /// (for example, when the browser is offline), so it is flagged as a
  /// network error.
  /// * Anything else is mapped to [MyAccountException.unknown].
  static MyAccountException fromJsObject(JSObject jsException) {
    final name = jsException.getProperty<JSString?>('name'.toJS)?.toDart;
    final message = jsException.getProperty<JSString?>('message'.toJS)?.toDart;

    if (name == 'MyAccountApiError') {
      final type = jsException.getProperty<JSString?>('type'.toJS)?.toDart;
      final title =
          jsException.getProperty<JSString?>('title'.toJS)?.toDart ?? '';
      final detail =
          jsException.getProperty<JSString?>('detail'.toJS)?.toDart ?? '';
      final status =
          jsException.getProperty<JSNumber?>('status'.toJS)?.toDartInt ?? 0;
      final validationErrors =
          jsException.getProperty<JSAny?>('validation_errors'.toJS).dartify();

      return MyAccountException(
          type ?? 'my_account_error',
          detail.isNotEmpty ? detail : title,
          {if (validationErrors != null) 'validation_errors': validationErrors},
          const {'isNetworkError': false},
          status,
          title,
          detail);
    }

    if (name == 'TypeError') {
      return MyAccountException('network_error', message ?? 'Network error',
          const {}, const {'isNetworkError': true}, 0, '', '');
    }

    return MyAccountException.unknown(message ?? jsException.toString());
  }
}
