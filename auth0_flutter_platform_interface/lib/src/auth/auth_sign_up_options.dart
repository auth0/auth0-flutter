class AuthSignUpOptions {
  late String email;
  late String password;
  late String connection;
  late Map<String, String>? userMetadata;

  AuthSignUpOptions(
      {required final String email,
      required final String password,
      required final String connection,
      final Map<String, String>? userMetadata}) {
    this.email = email;
    this.password = password;
    this.connection = connection;
    this.userMetadata = userMetadata;
  }
}
