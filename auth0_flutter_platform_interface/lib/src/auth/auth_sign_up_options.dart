class AuthSignUpOptions {
  late String email;
  late String password;
  late String connection;
  late Map<String, String> userMetadata;

  AuthSignUpOptions(
      this.email, this.password, this.connection, this.userMetadata);
}
