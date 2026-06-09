/// An enrolled passkey authentication method returned by the My Account API.
///
/// Returned by `enrollPasskey` after the passkey creation ceremony completes.
/// Exposes the passkey-specific metadata associated with the credential, in
/// addition to the common authentication-method fields.
class MyAccountPasskeyAuthenticationMethod {
  /// Unique identifier of the authentication method.
  final String id;

  /// Type of the authentication method. Equals `passkey`.
  final String type;

  /// Unique identifier of the user identity linked with the authentication
  /// method.
  final String? userIdentityId;

  /// The user agent of the browser or device used to enroll the passkey.
  final String? userAgent;

  /// Identifier of the passkey credential.
  final String? keyId;

  /// Public key of the passkey credential (base64-encoded).
  final String? publicKey;

  /// User handle associated with the passkey credential (base64url-encoded).
  final String? userHandle;

  /// Kind of device the credential is stored on (e.g. `single_device` or
  /// `multi_device`).
  final String? credentialDeviceType;

  /// Whether the passkey credential was backed up.
  final bool? credentialBackedUp;

  /// Authenticator Attestation GUID for the passkey provider.
  final String? aaguid;

  /// Relying party identifier for the domain.
  final String? relyingPartyId;

  /// Transports supported by the authenticator, if reported.
  final List<String>? transports;

  /// Creation date of the authentication method.
  final DateTime? createdAt;

  /// Usages of the authentication method (e.g. `mfa`).
  final List<String>? usage;

  const MyAccountPasskeyAuthenticationMethod({
    required this.id,
    required this.type,
    this.userIdentityId,
    this.userAgent,
    this.keyId,
    this.publicKey,
    this.userHandle,
    this.credentialDeviceType,
    this.credentialBackedUp,
    this.aaguid,
    this.relyingPartyId,
    this.transports,
    this.createdAt,
    this.usage,
  });

  factory MyAccountPasskeyAuthenticationMethod.fromMap(
          final Map<String, dynamic> result) =>
      MyAccountPasskeyAuthenticationMethod(
        id: result['id'] as String,
        type: result['type'] as String,
        userIdentityId: result['identity_user_id'] as String?,
        userAgent: result['user_agent'] as String?,
        keyId: result['key_id'] as String?,
        publicKey: result['public_key'] as String?,
        userHandle: result['user_handle'] as String?,
        credentialDeviceType: result['credential_device_type'] as String?,
        credentialBackedUp: result['credential_backed_up'] as bool?,
        aaguid: result['aaguid'] as String?,
        relyingPartyId: result['relying_party_id'] as String?,
        transports: (result['transports'] as List<dynamic>?)
            ?.map((final e) => e as String)
            .toList(),
        createdAt: result['created_at'] != null
            ? DateTime.parse(result['created_at'].toString())
            : null,
        usage: (result['usage'] as List<dynamic>?)
            ?.map((final e) => e as String)
            .toList(),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type,
        'identity_user_id': userIdentityId,
        'user_agent': userAgent,
        'key_id': keyId,
        'public_key': publicKey,
        'user_handle': userHandle,
        'credential_device_type': credentialDeviceType,
        'credential_backed_up': credentialBackedUp,
        'aaguid': aaguid,
        'relying_party_id': relyingPartyId,
        'transports': transports,
        'created_at': createdAt?.toUtc().toIso8601String(),
        'usage': usage,
      };
}
