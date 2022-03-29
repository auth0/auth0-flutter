import 'account.dart';
import 'credentials.dart';
import 'types.dart';

class AuthenticationApi {
  final Account account;

  AuthenticationApi(this.account);

  Future<void> login(
          {required final String usernameOrEmail,
          required final String password,
          required final String connectionOrRealm,
          final Set<String> scope = const {},
          final Map<String, Object> parameters = const {}}) =>
      Future.value();

  Future<Credentials> codeExchange(final String code) => Future.value(
      const Credentials(idToken: '', accessToken: '', expiresIn: 0));

  Future<UserProfile> userProfile({required final String accessToken}) =>
      Future.value({});

  Future<void> signup(
          {required final String email,
          required final String password,
          required final String connection,
          final Map<String, Object> userMetadata = const {}}) =>
      Future.value();

  Future<Credentials> renewAccessToken({required final String refreshToken}) =>
      Future.value(
          const Credentials(idToken: '', accessToken: '', expiresIn: 0));

  Future<void> resetPassword(
          {required final String email, required final String password}) =>
      Future.value();
}
