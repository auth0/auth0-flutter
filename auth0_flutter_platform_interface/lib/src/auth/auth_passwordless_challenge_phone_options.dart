import '../request/request_options.dart';
import 'delivery_method.dart';

class AuthPasswordlessChallengePhoneOptions implements RequestOptions {
  final String phoneNumber;
  final String connection;
  final DeliveryMethod deliveryMethod;
  final bool allowSignup;

  AuthPasswordlessChallengePhoneOptions({
    required this.phoneNumber,
    required this.connection,
    this.deliveryMethod = DeliveryMethod.text,
    this.allowSignup = false,
  });

  @override
  Map<String, dynamic> toMap() => {
        'phoneNumber': phoneNumber,
        'connection': connection,
        'deliveryMethod': deliveryMethod.value,
        'allowSignup': allowSignup,
      };
}
