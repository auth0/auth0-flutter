import '../actor_token.dart';
import '../request/request_options.dart';

class AuthCustomTokenExchangeOptions implements RequestOptions {
  final String subjectToken;
  final String subjectTokenType;
  final String? audience;
  final Set<String> scopes;
  final String? organization;

  /// The acting party in a delegation or impersonation flow. Because
  /// [ActorToken] bundles the token with its type, the pair can never be
  /// partially supplied.
  final ActorToken? actor;

  const AuthCustomTokenExchangeOptions({
    required this.subjectToken,
    required this.subjectTokenType,
    this.audience,
    this.scopes = const {},
    this.organization,
    this.actor,
  });

  @override
  Map<String, dynamic> toMap() => {
        'subjectToken': subjectToken,
        'subjectTokenType': subjectTokenType,
        if (audience != null) 'audience': audience,
        'scopes': scopes.toList(),
        if (organization != null) 'organization': organization,
        if (actor != null) ...{
          'actorToken': actor!.token,
          'actorTokenType': actor!.tokenType,
        },
      };
}
