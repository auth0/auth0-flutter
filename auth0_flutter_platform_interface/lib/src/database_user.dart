class DatabaseUser {
  final String email;
  final bool isEmailVerified;
  final String? username;

  DatabaseUser(
      {required this.email, required this.isEmailVerified, this.username});

  factory DatabaseUser.fromMap(final Map<dynamic, dynamic> result) =>
      DatabaseUser(
        email: result['email'] as String,
        isEmailVerified: result['emailVerified'] as bool,
        username: result['username'] as String?,
      );
}
