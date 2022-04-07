import '../account.dart';

class AuthLoginOptions {
  final Account account;
  final String usernameOrEmail;
  final String password;
  final String connectionOrRealm;
  final Set<String> scope;
  final Map<String, String> parameters;

  AuthLoginOptions(
      {required this.account,
      required this.usernameOrEmail,
      required this.password,
      required this.connectionOrRealm,
      this.scope = const {},
      this.parameters = const {}});

      Map<String, dynamic> toMap() => {
        'domain': account.domain,
        'clientId': account.clientId,
        'usernameOrEmail': usernameOrEmail,
        'password': password,
        'connectionOrRealm': connectionOrRealm,
        'scope': scope.toList(),
        'parameters': parameters
      };
}
