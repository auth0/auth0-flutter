class AuthResetPasswordOptions {
  late String email;
  late String connection;

  AuthResetPasswordOptions(
      {required final String email, required final String connection}) {
    this.email = email;
    this.connection = connection;
  }
}
