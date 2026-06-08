/// The authenticator's response to a passkey signup (registration).
///
/// Follows the standard WebAuthn registration response format.
class PasskeyAuthenticatorAttestationResponse {
  /// Base64URL-encoded client data JSON.
  final String clientDataJSON;

  /// Base64URL-encoded attestation object.
  final String attestationObject;

  const PasskeyAuthenticatorAttestationResponse({
    required this.clientDataJSON,
    required this.attestationObject,
  });

  factory PasskeyAuthenticatorAttestationResponse.fromMap(
          final Map<dynamic, dynamic> map) =>
      PasskeyAuthenticatorAttestationResponse(
        clientDataJSON: map['clientDataJSON'] as String,
        attestationObject: map['attestationObject'] as String,
      );

  Map<String, dynamic> toMap() => {
        'clientDataJSON': clientDataJSON,
        'attestationObject': attestationObject,
      };
}

/// A passkey signup credential obtained from the platform authenticator.
///
/// Your app obtains this by presenting the OS passkey creation UI (for example,
/// via Apple's `ASAuthorizationController` or Android's Credential Manager) and
/// passes it to `passkeySignup` to exchange it for Auth0 tokens. It follows the
/// standard WebAuthn public key credential format.
class PasskeySignupCredential {
  /// Base64URL-encoded credential identifier.
  final String id;

  /// Base64URL-encoded raw credential identifier.
  final String rawId;

  /// Credential type, typically `public-key`.
  final String type;

  /// How the authenticator is attached (`platform` or `cross-platform`).
  final String? authenticatorAttachment;

  /// The authenticator's attestation response.
  final PasskeyAuthenticatorAttestationResponse response;

  /// Results of any requested client extensions.
  final Map<String, dynamic>? clientExtensionResults;

  const PasskeySignupCredential({
    required this.id,
    required this.rawId,
    required this.type,
    required this.response,
    this.authenticatorAttachment,
    this.clientExtensionResults,
  });

  factory PasskeySignupCredential.fromMap(final Map<dynamic, dynamic> map) =>
      PasskeySignupCredential(
        id: map['id'] as String,
        rawId: map['rawId'] as String,
        type: map['type'] as String? ?? 'public-key',
        authenticatorAttachment: map['authenticatorAttachment'] as String?,
        response: PasskeyAuthenticatorAttestationResponse.fromMap(
            map['response'] as Map<dynamic, dynamic>),
        clientExtensionResults: map['clientExtensionResults'] == null
            ? null
            : Map<String, dynamic>.from(
                map['clientExtensionResults'] as Map<dynamic, dynamic>),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'rawId': rawId,
        'type': type,
        'authenticatorAttachment': authenticatorAttachment,
        'response': response.toMap(),
        'clientExtensionResults': clientExtensionResults,
      };
}
