import '../request/request_options.dart';

class AuthPasswordlessChallengeEmailOptions implements RequestOptions {
  final String email;
  final String connection;
  final bool allowSignup;

  AuthPasswordlessChallengeEmailOptions({
    required this.email,
    required this.connection,
    this.allowSignup = false,
  });

  @override
  Map<String, dynamic> toMap() => {
        'email': email,
        'connection': connection,
        'allowSignup': allowSignup,
      };
}
