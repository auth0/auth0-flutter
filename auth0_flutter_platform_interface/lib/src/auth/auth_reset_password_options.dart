import '../account.dart';

class AuthResetPasswordOptions {
  final Account account;
  final String email;
  final String connection;
  final Map<String, String> parameters;

  AuthResetPasswordOptions({
    required this.account,
    required this.email,
    required this.connection,
    this.parameters = const {},
  });

  Map<String, dynamic> toMap() => {
        'domain': account.domain,
        'clientId': account.clientId,
        'email': email,
        'connection': connection,
        'parameters': parameters
      };
}
