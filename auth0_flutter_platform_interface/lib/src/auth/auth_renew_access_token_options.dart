import '../account.dart';

class AuthRenewAccessTokenOptions {
  final Account account;
  final String refreshToken;
  final Set<String> scopes;

  AuthRenewAccessTokenOptions({
    required this.account,
    required this.refreshToken,
    this.scopes = const {},
  });

  Map<String, dynamic> toMap() => {
        'domain': account.domain,
        'clientId': account.clientId,
        'refreshToken': refreshToken,
        'scopes': scopes.toList(),
      };
}
