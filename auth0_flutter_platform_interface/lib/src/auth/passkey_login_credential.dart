/// The authenticator's response to a passkey login assertion.
///
/// Follows the standard WebAuthn authentication response format.
class PasskeyAuthenticatorAssertionResponse {
  /// Base64URL-encoded client data JSON.
  final String clientDataJSON;

  /// Base64URL-encoded authenticator data.
  final String authenticatorData;

  /// Base64URL-encoded assertion signature.
  final String signature;

  /// Base64URL-encoded user handle, if returned by the authenticator.
  final String? userHandle;

  const PasskeyAuthenticatorAssertionResponse({
    required this.clientDataJSON,
    required this.authenticatorData,
    required this.signature,
    this.userHandle,
  });

  factory PasskeyAuthenticatorAssertionResponse.fromMap(
          final Map<dynamic, dynamic> map) =>
      PasskeyAuthenticatorAssertionResponse(
        clientDataJSON: map['clientDataJSON'] as String,
        authenticatorData: map['authenticatorData'] as String,
        signature: map['signature'] as String,
        userHandle: map['userHandle'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'clientDataJSON': clientDataJSON,
        'authenticatorData': authenticatorData,
        'signature': signature,
        'userHandle': userHandle,
      };
}

/// A passkey login credential obtained from the platform authenticator.
///
/// This is the result of [createPasskeyCredential] (presenting the OS passkey
/// UI) and is passed to [passkeyLogin] to exchange it for Auth0 tokens. It
/// follows the standard WebAuthn public key credential format.
class PasskeyLoginCredential {
  /// Base64URL-encoded credential identifier.
  final String id;

  /// Base64URL-encoded raw credential identifier.
  final String rawId;

  /// Credential type, typically `public-key`.
  final String type;

  /// How the authenticator is attached (`platform` or `cross-platform`).
  final String? authenticatorAttachment;

  /// The authenticator's assertion response.
  final PasskeyAuthenticatorAssertionResponse response;

  /// Results of any requested client extensions.
  final Map<String, dynamic>? clientExtensionResults;

  const PasskeyLoginCredential({
    required this.id,
    required this.rawId,
    required this.type,
    required this.response,
    this.authenticatorAttachment,
    this.clientExtensionResults,
  });

  factory PasskeyLoginCredential.fromMap(final Map<dynamic, dynamic> map) =>
      PasskeyLoginCredential(
        id: map['id'] as String,
        rawId: map['rawId'] as String,
        type: map['type'] as String? ?? 'public-key',
        authenticatorAttachment: map['authenticatorAttachment'] as String?,
        response: PasskeyAuthenticatorAssertionResponse.fromMap(
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
