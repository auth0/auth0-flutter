import '../request/request_options.dart';

class AuthCustomTokenExchangeOptions implements RequestOptions {
  final String subjectToken;
  final String subjectTokenType;
  final String? audience;
  final Set<String> scopes;
  final String? organization;

  /// The token representing the acting party in a delegation or impersonation
  /// flow. When provided, [actorTokenType] must also be provided.
  final String? actorToken;

  /// A URI identifying the type of the [actorToken]. When provided,
  /// [actorToken] must also be provided.
  final String? actorTokenType;

  const AuthCustomTokenExchangeOptions({
    required this.subjectToken,
    required this.subjectTokenType,
    this.audience,
    this.scopes = const {},
    this.organization,
    this.actorToken,
    this.actorTokenType,
  });

  @override
  Map<String, dynamic> toMap() => {
        'subjectToken': subjectToken,
        'subjectTokenType': subjectTokenType,
        if (audience != null) 'audience': audience,
        'scopes': scopes.toList(),
        if (organization != null) 'organization': organization,
        if (actorToken != null) 'actorToken': actorToken,
        if (actorTokenType != null) 'actorTokenType': actorTokenType,
      };
}
