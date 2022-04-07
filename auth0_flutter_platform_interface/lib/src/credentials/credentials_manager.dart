import '../credentials.dart';

abstract class CredentialsManager {
  Future<Credentials> get();
  Future<void> set(final Credentials credentials);
  Future<void> clear();
}
