import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter/services.dart';

/// Bridges to the platform authenticator (iOS/macOS
/// `ASAuthorizationController`, Android Credential Manager) to obtain a passkey
/// assertion (login) or create a passkey and obtain its attestation (signup).
///
/// The `auth0_flutter` SDK deliberately does **not** present the OS passkey UI;
/// it only requests the challenge (`passkeyLoginChallenge` /
/// `passkeySignupChallenge`) and exchanges a credential for tokens
/// (`passkeyCredentialExchange`). This class shows how an app can fill that gap
/// with a small native plumbing layer. Both methods return the unified
/// [PasskeyCredential].
class PasskeyAuthenticator {
  static const MethodChannel _channel =
      MethodChannel('com.auth0.auth0_flutter_example/passkey');

  /// Presents the OS passkey UI for [challenge] and returns the resulting login
  /// [PasskeyCredential] (a WebAuthn assertion), ready to pass to
  /// `passkeyCredentialExchange`.
  ///
  /// Throws a [PlatformException] if the user cancels or the OS fails to
  /// produce an assertion.
  static Future<PasskeyCredential> getAssertion(
    final PasskeyChallenge challenge,
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

    final response =
        Map<String, dynamic>.from(result['response'] as Map<dynamic, dynamic>);

    return PasskeyCredential(
      id: result['id'] as String,
      rawId: result['rawId'] as String,
      type: (result['type'] as String?) ?? 'public-key',
      authenticatorAttachment: result['authenticatorAttachment'] as String?,
      response: PasskeyAuthenticatorResponse(
        clientDataJSON: response['clientDataJSON'] as String,
        authenticatorData: response['authenticatorData'] as String?,
        signature: response['signature'] as String?,
        userHandle: response['userHandle'] as String?,
      ),
    );
  }

  /// Presents the OS passkey creation UI for [challenge] and returns the
  /// resulting signup [PasskeyCredential] (a WebAuthn attestation), ready to
  /// pass to `passkeyCredentialExchange`.
  ///
  /// The whole `authParamsPublicKey` map is forwarded to the native side, which
  /// extracts what each platform's authenticator API needs (iOS reads the
  /// individual fields; Android passes it on as WebAuthn JSON).
  ///
  /// Throws a [PlatformException] if the user cancels or the OS fails to
  /// produce an attestation.
  static Future<PasskeyCredential> getAttestation(
      final PasskeyChallenge challenge) async {
    final result = await _channel.invokeMapMethod<String, dynamic>(
      'getAttestation',
      <String, dynamic>{
        'authParamsPublicKey': challenge.authParamsPublicKey,
      },
    );

    if (result == null) {
      throw PlatformException(
        code: 'no_credential',
        message: 'The platform authenticator returned no credential.',
      );
    }

    final response =
        Map<String, dynamic>.from(result['response'] as Map<dynamic, dynamic>);

    return PasskeyCredential(
      id: result['id'] as String,
      rawId: result['rawId'] as String,
      type: (result['type'] as String?) ?? 'public-key',
      authenticatorAttachment: result['authenticatorAttachment'] as String?,
      response: PasskeyAuthenticatorResponse(
          clientDataJSON: response['clientDataJSON'] as String,
          attestationObject: response['attestationObject'] as String?),
    );
  }
}
