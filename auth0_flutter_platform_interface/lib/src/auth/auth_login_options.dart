class AuthLoginOptions {
  late String usernameOrEmail;
  late String password;
  late String connectionOrRealm;
  late Set<String>? scope;
  late Map<String, String>? parameters;

  AuthLoginOptions(
      {required final String usernameOrEmail,
      required final String password,
      required final String connectionOrRealm,
      final Set<String>? scope,
      final Map<String, String>? parameters}) {
    this.usernameOrEmail = usernameOrEmail;
    this.password = password;
    this.connectionOrRealm = connectionOrRealm;
    this.scope = scope;
    this.parameters = parameters;
  }
}
