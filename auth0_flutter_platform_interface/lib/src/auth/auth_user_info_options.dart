import '../request/request_options.dart';

class AuthUserInfoOptions implements RequestOptions {
  final String accessToken;
  final String tokenType;
  final Map<String, String> parameters;

  AuthUserInfoOptions(
      {required this.accessToken,
      this.tokenType = 'Bearer',
      this.parameters = const {}});

  @override
  Map<String, dynamic> toMap() => {
        'accessToken': accessToken,
        'tokenType': tokenType,
        'parameters': parameters,
      };
}
