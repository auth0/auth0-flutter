import '../request/request_options.dart';

class AuthLoginWithSocialTokenOptions implements RequestOptions {
  final String accessToken;
  final String? audience;
  final Set<String> scopes;
  final Map<String, String> parameters;
  final Map<String, dynamic>? profile;

  AuthLoginWithSocialTokenOptions({
    required this.accessToken,
    this.audience,
    this.scopes = const {},
    this.parameters = const {},
    this.profile,
  });

  @override
  Map<String, dynamic> toMap() => {
        'accessToken': accessToken,
        'audience': audience,
        'scopes': scopes.toList(),
        'parameters': parameters,
        'profile': profile
      };
}
