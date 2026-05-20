class AuthenticationMethod {
  final String id;
  final String type;
  final String? name;
  final String? phoneNumber;
  final String? email;
  final String? totpSecret;
  final String? totpUri;
  final String? preferredAuthenticationMethod;
  final DateTime? createdAt;
  final DateTime? lastAuthAt;

  const AuthenticationMethod({
    required this.id,
    required this.type,
    this.name,
    this.phoneNumber,
    this.email,
    this.totpSecret,
    this.totpUri,
    this.preferredAuthenticationMethod,
    this.createdAt,
    this.lastAuthAt,
  });

  factory AuthenticationMethod.fromMap(final Map<String, dynamic> result) =>
      AuthenticationMethod(
        id: result['id'] as String,
        type: result['type'] as String,
        name: result['name'] as String?,
        phoneNumber: result['phone_number'] as String?,
        email: result['email'] as String?,
        totpSecret: result['totp_secret'] as String?,
        totpUri: result['totp_uri'] as String?,
        preferredAuthenticationMethod:
            result['preferred_authentication_method'] as String?,
        createdAt: result['created_at'] != null
            ? DateTime.parse(result['created_at'] as String)
            : null,
        lastAuthAt: result['last_auth_at'] != null
            ? DateTime.parse(result['last_auth_at'] as String)
            : null,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type,
        'name': name,
        'phone_number': phoneNumber,
        'email': email,
        'totp_secret': totpSecret,
        'totp_uri': totpUri,
        'preferred_authentication_method': preferredAuthenticationMethod,
        'created_at': createdAt?.toUtc().toIso8601String(),
        'last_auth_at': lastAuthAt?.toUtc().toIso8601String(),
      };
}
