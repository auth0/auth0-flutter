import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter/services.dart';

/// Bridges to the platform authenticator (iOS/macOS
/// `ASAuthorizationController`, Android Credential Manager) to obtain a passkey
/// assertion.
///
/// The `auth0_flutter` SDK deliberately does **not** present the OS passkey UI;
/// it only requests the login challenge (`passkeyLoginChallenge`) and exchanges
/// a credential for tokens (`passkeyLogin`). This class shows how an app can
/// fill that gap with a small native plumbing layer.
class PasskeyAuthenticator {
  static const MethodChannel _channel =
      MethodChannel('com.auth0.auth0_flutter_example/passkey');

  /// Presents the OS passkey UI for [challenge] and returns the resulting
  /// [PasskeyLoginCredential], ready to pass to `passkeyLogin`.
  ///
  /// Throws a [PlatformException] if the user cancels or the OS fails to
  /// produce an assertion.
  static Future<PasskeyLoginCredential> getAssertion(
    final PasskeyLoginChallenge challenge,
  ) async {
    final authParamsPublicKey = challenge.authParamsPublicKey;

    final result = await _channel.invokeMapMethod<String, dynamic>(
      'getAssertion',
      <String, dynamic>{
        'challenge': authParamsPublicKey['challenge'],
        'rpId': authParamsPublicKey['rpId'],
      },
    );

    if (result == null) {
      throw PlatformException(
        code: 'no_credential',
        message: 'The platform authenticator returned no credential.',
      );
    }

    final response = Map<String, dynamic>.from(
        result['response'] as Map<dynamic, dynamic>);

    return PasskeyLoginCredential(
      id: result['id'] as String,
      rawId: result['rawId'] as String,
      type: (result['type'] as String?) ?? 'public-key',
      authenticatorAttachment: result['authenticatorAttachment'] as String?,
      response: PasskeyAuthenticatorAssertionResponse(
        clientDataJSON: response['clientDataJSON'] as String,
        authenticatorData: response['authenticatorData'] as String,
        signature: response['signature'] as String,
        userHandle: response['userHandle'] as String?,
      ),
    );
  }
}
