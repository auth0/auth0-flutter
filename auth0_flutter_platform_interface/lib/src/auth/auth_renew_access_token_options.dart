import '../account.dart';

class AuthRenewAccessTokenOptions {
  final Account account;
  final String refreshToken;
  final Set<String> scopes;
  final Map<String, String> parameters;

  AuthRenewAccessTokenOptions({
    required this.account,
    required this.refreshToken,
    this.scopes = const {},
    this.parameters = const {},
  });

  Map<String, dynamic> toMap() => {
        'domain': account.domain,
        'clientId': account.clientId,
        'refreshToken': refreshToken,
        'scopes': scopes.toList(),
        'parameters': parameters
      };
}
