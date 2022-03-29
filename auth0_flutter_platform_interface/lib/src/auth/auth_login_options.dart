class AuthLoginOptions {
  final String usernameOrEmail;
  final String password;
  final String connectionOrRealm;
  final Set<String> scope;
  final Map<String, String> parameters;

  AuthLoginOptions(
      {required this.usernameOrEmail,
      required this.password,
      required this.connectionOrRealm,
      this.scope = const {},
      this.parameters = const {}});
}
