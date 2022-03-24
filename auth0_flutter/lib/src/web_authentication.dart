import 'account.dart';
import 'results.dart';

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
          final Map<String, Object>? parameters}) =>
      Future.value(const LoginResult(
          idToken: '', accessToken: '', expiresIn: 0, userProfile: {}));
}
