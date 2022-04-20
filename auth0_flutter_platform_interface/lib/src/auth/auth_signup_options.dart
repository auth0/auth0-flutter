import '../request/request_options.dart';

class AuthSignupOptions implements RequestOptions {
  final String email;
  final String? username;
  final String password;
  final String connection;
  final Map<String, String> userMetadata;

  AuthSignupOptions(
      {required this.email,
      this.username,
      required this.password,
      required this.connection,
      this.userMetadata = const {}});

  @override
  Map<String, dynamic> toMap() => {
        'connection': connection,
        'username': username,
        'email': email,
        'password': password,
        'userMetadata': userMetadata
      };
}
