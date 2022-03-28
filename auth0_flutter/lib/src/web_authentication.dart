import 'account.dart';
import 'credentials.dart';
import 'types.dart';
import 'validation.dart';

class LoginResult extends Credentials {
  final UserProfile userProfile;

  const LoginResult(
      {required final String idToken,
      required final String accessToken,
      final String? refreshToken,
      required final int expiresIn,
      final Set<String>? scopes,
      required this.userProfile})
      : super(
            idToken: idToken,
            accessToken: accessToken,
            refreshToken: refreshToken,
            expiresIn: expiresIn,
            scopes: scopes);
}

class WebAuthentication {
  final Account account;

  WebAuthentication(this.account);

  Future<LoginResult> login(
          {final String? audience,
          final Set<String>? scopes,
          final String? redirectUri,
          final String? organizationId,
          final String? invitationUrl,
          final bool useEphemeralSession = false,
          final Map<String, Object> parameters = const {},
          final IdTokenValidationConfig idTokenValidationConfig =
              const IdTokenValidationConfig()}) =>
      Future.value(const LoginResult(
          idToken: '', accessToken: '', expiresIn: 0, userProfile: {}));

  Future<void> logout({final String? returnTo}) => Future.value();
}
