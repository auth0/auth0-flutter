import '../request/request_options.dart';
import 'phone_type.dart';

class MyAccountEnrollPhoneOptions implements RequestOptions {
  final String accessToken;
  final String phoneNumber;
  final PhoneType type;

  MyAccountEnrollPhoneOptions({
    required this.accessToken,
    required this.phoneNumber,
    required this.type,
  });

  @override
  Map<String, dynamic> toMap() => {
        'accessToken': accessToken,
        'phoneNumber': phoneNumber,
        'type': type.toValue(),
      };
}
