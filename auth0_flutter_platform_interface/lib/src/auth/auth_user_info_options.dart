import '../account.dart';

class AuthUserInfoOptions {
  String accessToken;
  Account account;

  AuthUserInfoOptions(
      {required final this.accessToken, required final this.account});

  Map<String, dynamic> toMap() => {
        'domain': account.domain,
        'clientId': account.clientId,
        'accessToken': accessToken,
      };
}
