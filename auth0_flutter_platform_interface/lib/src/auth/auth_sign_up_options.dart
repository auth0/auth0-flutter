class AuthSignUpOptions {
  final String email;
  final String password;
  final String connection;
  final Map<String, String> userMetadata;

  AuthSignUpOptions(
      {required this.email,
      required this.password,
      required this.connection,
      this.userMetadata = const {}});
}
