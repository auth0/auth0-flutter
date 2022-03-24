class AuthLoginOptions {
  late String usernameOrEmail;
  late String password;
  late String connectionOrRealm;
  late String scope;
  late String parameters;

  AuthLoginOptions(this.usernameOrEmail, this.password,
      this.connectionOrRealm, this.scope, this.parameters);
}
