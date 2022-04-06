import '../account.dart';

class WebAuthLogoutInput {
  final Account account;
  final String? returnTo;
  final String? scheme;

  WebAuthLogoutInput({required this.account, this.returnTo, this.scheme});

  Map<String, dynamic> toMap() => {
        'domain': account.domain,
        'clientId': account.clientId,
        'returnTo': returnTo,
        'scheme': scheme
      };
}
