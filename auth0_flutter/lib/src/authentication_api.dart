import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';

class AuthenticationApi {
  final Account account;
  final Telemetry telemetry;

  AuthenticationApi(this.account, this.telemetry);

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
          telemetry: telemetry,
          parameters: parameters));

  Future<UserProfile> userProfile({required final String accessToken}) =>
      Auth0FlutterAuthPlatform.instance.userInfo(AuthUserInfoOptions(
          accessToken: accessToken, account: account, telemetry: telemetry));

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
          account: account,
          telemetry: telemetry));

  Future<Credentials> renewAccessToken(
          {required final String refreshToken,
          final Set<String> scopes = const {},
          final Map<String, String> parameters = const {}}) =>
      Auth0FlutterAuthPlatform.instance.renewAccessToken(
          AuthRenewAccessTokenOptions(
              account: account,
              telemetry: telemetry,
              refreshToken: refreshToken,
              scopes: scopes,
              parameters: parameters));

  Future<void> resetPassword(
          {required final String email,
          required final String connection,
          final Map<String, String> parameters = const {}}) =>
      Auth0FlutterAuthPlatform.instance.resetPassword(AuthResetPasswordOptions(
          account: account,
          telemetry: telemetry,
          email: email,
          connection: connection,
          parameters: parameters));
}
