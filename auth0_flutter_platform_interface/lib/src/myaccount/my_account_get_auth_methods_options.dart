import '../request/request_options.dart';

class MyAccountGetAuthMethodsOptions implements RequestOptions {
  final String accessToken;

  MyAccountGetAuthMethodsOptions({required this.accessToken});

  @override
  Map<String, dynamic> toMap() => {
        'accessToken': accessToken,
      };
}
