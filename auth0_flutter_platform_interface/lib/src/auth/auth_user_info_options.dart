import '../request/request_options.dart';

class AuthUserInfoOptions implements RequestOptions {
  final String accessToken;
  final Map<String, String> parameters;

  AuthUserInfoOptions({required this.accessToken, this.parameters = const {}});

  @override
  Map<String, dynamic> toMap() => {
        'accessToken': accessToken,
        'parameters': parameters,
      };
}
