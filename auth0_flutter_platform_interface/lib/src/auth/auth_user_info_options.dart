import '../request/request_options.dart';

class AuthUserInfoOptions implements RequestOptions {
  String accessToken;

  AuthUserInfoOptions({required final this.accessToken});

  @override
  Map<String, dynamic> toMap() => {
        'accessToken': accessToken,
      };
}
