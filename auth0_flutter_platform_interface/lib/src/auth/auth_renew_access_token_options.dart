import '../account.dart';

class AuthRenewAccessTokenOptions {
  final Account account;
  final String refreshToken;
  final Set<String> scope;

  AuthRenewAccessTokenOptions({
    required this.account,
    required this.refreshToken,
    this.scope = const {},
  });

  Map<String, dynamic> toMap() => {
        'domain': account.domain,
        'clientId': account.clientId,
        'refreshToken': refreshToken,
        'scope': scope.toList(),
      };
}
