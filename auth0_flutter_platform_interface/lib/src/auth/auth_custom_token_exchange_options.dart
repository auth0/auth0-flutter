import '../request/request_options.dart';

class AuthCustomTokenExchangeOptions implements RequestOptions {
  final String subjectToken;
  final String subjectTokenType;
  final String? audience;
  final Set<String> scopes;
  final String? organization;

  const AuthCustomTokenExchangeOptions({
    required this.subjectToken,
    required this.subjectTokenType,
    this.audience,
    this.scopes = const {},
    this.organization,
  });

  @override
  Map<String, dynamic> toMap() => {
        'subjectToken': subjectToken,
        'subjectTokenType': subjectTokenType,
        if (audience != null) 'audience': audience,
        'scopes': scopes.toList(),
        if (organization != null) 'organization': organization,
      };
}
