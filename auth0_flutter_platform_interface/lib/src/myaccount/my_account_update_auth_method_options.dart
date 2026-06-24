import '../request/request_options.dart';
import 'phone_type.dart';

class MyAccountUpdateAuthMethodOptions implements RequestOptions {
  final String accessToken;
  final String id;
  final String? name;
  final PhoneType? preferredAuthenticationMethod;

  MyAccountUpdateAuthMethodOptions({
    required this.accessToken,
    required this.id,
    this.name,
    this.preferredAuthenticationMethod,
  });

  @override
  Map<String, dynamic> toMap() => {
        'accessToken': accessToken,
        'id': id,
        'name': name,
        'preferredAuthenticationMethod':
            preferredAuthenticationMethod?.toValue(),
      };
}
