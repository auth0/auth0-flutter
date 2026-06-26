/// The authenticator's response within a [PasskeyCredential].
///
/// Follows the standard WebAuthn response format. A login (assertion) response
/// carries [authenticatorData], [signature], and optionally [userHandle]; a
/// signup (attestation) response carries [attestationObject]. The fields not
/// relevant to a given ceremony are left null.
class PasskeyAuthenticatorResponse {
  /// Base64URL-encoded client data JSON. Present for both login and signup.
  final String clientDataJSON;

  /// Base64URL-encoded authenticator data (login assertion only).
  final String? authenticatorData;

  /// Base64URL-encoded assertion signature (login assertion only).
  final String? signature;

  /// Base64URL-encoded user handle, if returned by the authenticator
  /// (login assertion only).
  final String? userHandle;

  /// Base64URL-encoded attestation object (signup registration only).
  final String? attestationObject;

  const PasskeyAuthenticatorResponse({
    required this.clientDataJSON,
    this.authenticatorData,
    this.signature,
    this.userHandle,
    this.attestationObject,
  });

  factory PasskeyAuthenticatorResponse.fromMap(
          final Map<dynamic, dynamic> map) =>
      PasskeyAuthenticatorResponse(
        clientDataJSON: map['clientDataJSON'] as String,
        authenticatorData: map['authenticatorData'] as String?,
        signature: map['signature'] as String?,
        userHandle: map['userHandle'] as String?,
        attestationObject: map['attestationObject'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'clientDataJSON': clientDataJSON,
        if (authenticatorData != null) 'authenticatorData': authenticatorData,
        if (signature != null) 'signature': signature,
        if (userHandle != null) 'userHandle': userHandle,
        if (attestationObject != null) 'attestationObject': attestationObject,
      };
}

/// A passkey credential obtained from the platform authenticator.
///
/// Your app presents the OS passkey UI (for example, via Apple's
/// `ASAuthorizationController` or Android's Credential Manager) and constructs
/// this from the resulting assertion (login) or attestation (signup), then
/// passes it to `passkeyCredentialExchange` to exchange it for Auth0 tokens. It
/// follows the standard WebAuthn public key credential format.
class PasskeyCredential {
  /// Base64URL-encoded credential identifier.
  final String id;

  /// Base64URL-encoded raw credential identifier.
  final String rawId;

  /// Credential type, typically `public-key`.
  final String type;

  /// How the authenticator is attached (`platform` or `cross-platform`).
  final String? authenticatorAttachment;

  /// The authenticator's response (assertion for login, attestation for
  /// signup).
  final PasskeyAuthenticatorResponse response;

  /// Results of any requested client extensions.
  final Map<String, dynamic>? clientExtensionResults;

  const PasskeyCredential({
    required this.id,
    required this.rawId,
    required this.type,
    required this.response,
    this.authenticatorAttachment,
    this.clientExtensionResults,
  });

  factory PasskeyCredential.fromMap(final Map<dynamic, dynamic> map) =>
      PasskeyCredential(
        id: map['id'] as String,
        rawId: map['rawId'] as String,
        type: map['type'] as String? ?? 'public-key',
        authenticatorAttachment: map['authenticatorAttachment'] as String?,
        response: PasskeyAuthenticatorResponse.fromMap(
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
