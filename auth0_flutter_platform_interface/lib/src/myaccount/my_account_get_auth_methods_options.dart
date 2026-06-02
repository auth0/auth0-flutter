import '../request/request_options.dart';
import 'authentication_method_type.dart';

class MyAccountGetAuthMethodsOptions implements RequestOptions {
  final String accessToken;
  final AuthenticationMethodType? type;

  MyAccountGetAuthMethodsOptions({required this.accessToken, this.type});

  @override
  Map<String, dynamic> toMap() => {
        'accessToken': accessToken,
        'type': type?.toValue(),
      };
}
