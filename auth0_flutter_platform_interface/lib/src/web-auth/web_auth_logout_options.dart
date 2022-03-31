import '../account.dart';

class WebAuthLogoutOptions {
  final Account account;
  final String? returnTo;

  WebAuthLogoutOptions({
    required this.account, this.returnTo
  });

  Map<String, dynamic> toMap() => {
        'domain': account.domain,
        'clientId': account.clientId,
        'returnTo': returnTo
      };
}
