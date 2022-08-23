import '../request/request_options.dart';

class AuthResetPasswordOptions implements RequestOptions {
  final String email;
  final String connection;
  final Map<String, String> parameters;

  AuthResetPasswordOptions({
    required this.email,
    required this.connection,
    this.parameters = const {},
  });

  @override
  Map<String, dynamic> toMap() =>
      {'email': email, 'connection': connection, 'parameters': parameters};
}
