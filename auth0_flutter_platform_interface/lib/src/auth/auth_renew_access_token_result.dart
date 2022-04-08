import '../credentials.dart';
import '../user_profile.dart';

class AuthRenewAccessTokenResult extends Credentials {

  final UserProfile userProfile;

  AuthRenewAccessTokenResult(
      {required final String idToken,
      required final String accessToken,
      final String? refreshToken,
      required final DateTime expiresAt,
      final Set<String> scopes = const {},
      required this.userProfile}) : super(
            idToken: idToken,
            accessToken: accessToken,
            refreshToken: refreshToken,
            expiresAt: expiresAt,
            scopes: scopes);

      factory AuthRenewAccessTokenResult.fromMap(final Map<dynamic, dynamic> result) => AuthRenewAccessTokenResult(
        userProfile: Map<String, dynamic>.from(
            result['userProfile'] as Map<dynamic, dynamic>),
        idToken: result['idToken'] as String,
        accessToken: result['accessToken'] as String,
        refreshToken: result['refreshToken'] as String?,
        expiresAt: DateTime.parse(result['expiresAt'] as String),
        scopes: Set<String>.from(result['scopes'] as List<Object?>),
      );
}
