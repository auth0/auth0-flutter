import '../account.dart';

class AuthSignUpOptions {
  final Account account;
  final String email;
  final String? username;
  final String password;
  final String connection;
  final Map<String, String> userMetadata;

  AuthSignUpOptions(
      {required this.account,
      required this.email,
      this.username,
      required this.password,
      required this.connection,
      this.userMetadata = const {}});

  Map<String, dynamic> toMap() => {
        'domain': account.domain,
        'clientId': account.clientId,
        'connection': connection,
        'username': username,
        'email': email,
        'password': password,
        'userMetadata': userMetadata
      };
}
