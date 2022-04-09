class DatabaseUser {
  final String email;
  final bool emailVerified;
  final String? username;

  DatabaseUser(
      {required this.email,
      required this.emailVerified,
      this.username});

  factory DatabaseUser.fromMap(final Map<dynamic, dynamic> result) =>
      DatabaseUser(
        email: result['email'] as String,
        emailVerified: result['emailVerified'] as bool,
        username: result['username'] as String?,
      );
}
