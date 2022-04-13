import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';

class AuthenticationApi {
  final Account account;

  AuthenticationApi(this.account);

  Future<Credentials> login(
          {required final String usernameOrEmail,
          required final String password,
          required final String connectionOrRealm,
          final Set<String> scopes = const {},
          final Map<String, String> parameters = const {}}) =>
      Auth0FlutterAuthPlatform.instance.login(AuthLoginOptions(
          usernameOrEmail: usernameOrEmail,
          password: password,
          connectionOrRealm: connectionOrRealm,
          scopes: scopes,
          account: account,
          parameters: parameters));

  Future<Credentials> codeExchange(final String code) => Future.value(
      Credentials(idToken: '', accessToken: '', expiresAt: DateTime.now()));

  Future<AuthUserInfoResult> userProfile({required final String accessToken}) =>
      Auth0FlutterAuthPlatform.instance.userInfo(AuthUserInfoOptions(accessToken: accessToken, account: account));

  Future<DatabaseUser> signup(
          {required final String email,
          required final String password,
          final String? username,
          required final String connection,
          final Map<String, String> userMetadata = const {}}) =>
      Auth0FlutterAuthPlatform.instance.signup(AuthSignupOptions(
          email: email,
          password: password,
          connection: connection,
          username: username,
          userMetadata: userMetadata,
          account: account));

  Future<Credentials> renewAccessToken({required final String refreshToken}) =>
      Future.value(
          Credentials(idToken: '', accessToken: '', expiresAt: DateTime.now()));

  Future<void> resetPassword(
          {required final String email, required final String connection}) =>
      Future.value();
}
