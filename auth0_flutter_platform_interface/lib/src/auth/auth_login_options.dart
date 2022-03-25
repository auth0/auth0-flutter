class AuthLoginOptions {
  late String usernameOrEmail;
  late String password;
  late String connectionOrRealm;
  late Set<String> scope;
  late Map<String, String> parameters;

  AuthLoginOptions(this.usernameOrEmail, this.password,
      this.connectionOrRealm, this.scope, this.parameters);
}
