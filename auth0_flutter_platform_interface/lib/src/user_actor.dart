/// Represents the `act` (actor) claim from an ID token issued during a Custom
/// Token Exchange delegation or impersonation flow.
///
/// The `act` claim identifies the acting party — the entity performing actions
/// on behalf of the subject (for example, an AI agent or a support
/// representative). It is set server-side via an Auth0 Action using the
/// `api.authentication.setActor()` command.
///
/// The claim may be nested to represent delegation chains (`act.act` for
/// multi-hop delegation); the full structure is preserved.
///
/// See also:
/// * [RFC 8693 Section 4.4](https://tools.ietf.org/html/rfc8693#section-4.4)
/// * [Custom Token Exchange Documentation](https://auth0.com/docs/authenticate/custom-token-exchange)
class UserActor {
  /// The subject identifier of the acting party.
  ///
  /// Per [RFC 8693 Section 4.4](https://tools.ietf.org/html/rfc8693#section-4.4),
  /// `sub` is required within an `act` claim. An `act` claim without a `sub` is
  /// considered invalid and is not parsed.
  final String sub;

  /// A nested actor claim representing the next actor in a delegation chain.
  final UserActor? actor;

  /// Any additional claims beyond `sub` and `act` (for example `org`, `role`).
  ///
  /// Values are preserved as-is so that custom properties set via
  /// `api.authentication.setActor()` are not lost.
  final Map<String, dynamic> extraClaims;

  const UserActor({
    required this.sub,
    this.actor,
    this.extraClaims = const {},
  });

  /// Creates a [UserActor] from a decoded `act` claim map, or returns `null` if
  /// the map does not contain a `sub` claim.
  static UserActor? fromMap(final Map<dynamic, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final sub = map['sub'];
    if (sub is! String) {
      return null;
    }

    final nested = map['act'];
    final extra = <String, dynamic>{};
    for (final entry in map.entries) {
      if (entry.key != 'sub' && entry.key != 'act') {
        extra['${entry.key}'] = entry.value;
      }
    }

    return UserActor(
      sub: sub,
      actor: nested is Map ? UserActor.fromMap(nested) : null,
      extraClaims: extra,
    );
  }

  Map<String, dynamic> toMap() => {
        ...extraClaims,
        'sub': sub,
        if (actor != null) 'act': actor!.toMap(),
      };
}
