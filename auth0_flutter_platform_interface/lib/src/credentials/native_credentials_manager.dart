import '../account.dart';
import '../credentials.dart';
import 'credentials_manager.dart';

class NativeCredentialsManager implements CredentialsManager {
  final Account account;

  NativeCredentialsManager(final String domain, final String clientId)
      : account = Account(domain, clientId);

  @override
  Future<void> clear() => Future.value();

  @override
  Future<Credentials> get() => Future.value(
      Credentials(idToken: '', accessToken: '', expiresAt: DateTime.now()));

  @override
  Future<void> set(final Credentials credentials) => Future.value();
}
