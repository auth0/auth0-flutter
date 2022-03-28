class AuthLoginOptions {
  late String usernameOrEmail;
  late String password;
  late String connectionOrRealm;
  late Set<String> scope;
  late Map<String, String> parameters;

  AuthLoginOptions(
      {required this.usernameOrEmail,
      required this.password,
      required this.connectionOrRealm,
      this.scope = const {},
      this.parameters = const {}});
}
