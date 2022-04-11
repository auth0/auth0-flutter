class Credentials {
  late String idToken;
  late String accessToken;
  late String? refreshToken;
  late DateTime expiresAt;
  late Set<String> scopes;

  Credentials(
      {required this.idToken,
      required this.accessToken,
      this.refreshToken,
      required this.expiresAt,
      this.scopes = const {}});

  Credentials.fromMap(final Map<dynamic, dynamic> result) {
    idToken = result['idToken'] as String;
    accessToken = result['accessToken'] as String;
    refreshToken = result['refreshToken'] as String?;
    expiresAt = DateTime.parse(result['expiresAt'] as String);
    scopes = Set<String>.from(result['scopes'] as List<Object?>);
  }
}
