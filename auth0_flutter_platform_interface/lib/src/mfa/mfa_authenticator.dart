/// An MFA authenticator enrolled by the user, as returned by
/// `MfaApi.getAuthenticators`.
class MfaAuthenticator {
  /// The identifier of the authenticator, in the form `{type}|{id}`, e.g.
  /// `sms|dev_authenticator_id`.
  final String id;

  /// The factor type used when filtering by `mfa_requirements`, e.g. `phone`,
  /// `email`, `otp`, `push-notification`.
  ///
  /// Only present when the tenant has the `mfa_authenticators_enable_type`
  /// flag enabled.
  final String? type;

  /// The underlying authenticator type, e.g. `oob`, `otp`, `recovery-code`.
  final String? authenticatorType;

  /// Whether the authenticator is active (fully enrolled).
  final bool active;

  /// The out-of-band channel for `oob` authenticators, e.g. `sms`, `email`,
  /// `auth0` (Push). `null` for non-OOB authenticators.
  final String? oobChannel;

  /// A human-readable name for the authenticator, e.g. a masked phone number
  /// or email.
  final String? name;

  const MfaAuthenticator({
    required this.id,
    this.type,
    this.authenticatorType,
    this.active = false,
    this.oobChannel,
    this.name,
  });

  factory MfaAuthenticator.fromMap(final Map<String, dynamic> result) =>
      MfaAuthenticator(
        id: result['id'] as String,
        type: result['type'] as String?,
        authenticatorType: result['authenticator_type'] as String?,
        active: result['active'] as bool? ?? false,
        oobChannel: result['oob_channel'] as String?,
        name: result['name'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type,
        'authenticator_type': authenticatorType,
        'active': active,
        'oob_channel': oobChannel,
        'name': name,
      };
}
