import '../request/request_options.dart';

class AuthRenewOptions implements RequestOptions {
  final String refreshToken;
  final Set<String> scopes;
  final Map<String, String> parameters;

  AuthRenewOptions({
    required this.refreshToken,
    this.scopes = const {},
    this.parameters = const {},
  });

  @override
  Map<String, dynamic> toMap() => {
        'refreshToken': refreshToken,
        'scopes': scopes.toList(),
        'parameters': parameters
      };
}
