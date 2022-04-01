import '../account.dart';

class WebAuthLogoutInput {
  final Account account;
  final String? returnTo;

  WebAuthLogoutInput({
    required this.account, this.returnTo
  });

  Map<String, dynamic> toMap() => {
        'domain': account.domain,
        'clientId': account.clientId,
        'returnTo': returnTo
      };
}
