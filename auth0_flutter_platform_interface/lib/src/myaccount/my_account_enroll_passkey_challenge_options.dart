import '../request/request_options.dart';

class MyAccountEnrollPasskeyChallengeOptions implements RequestOptions {
  final String accessToken;
  final String? userIdentityId;
  final String? connection;

  MyAccountEnrollPasskeyChallengeOptions({
    required this.accessToken,
    this.userIdentityId,
    this.connection,
  });

  @override
  Map<String, dynamic> toMap() => {
        'accessToken': accessToken,
        if (userIdentityId != null) 'userIdentityId': userIdentityId,
        if (connection != null) 'connection': connection,
      };
}
