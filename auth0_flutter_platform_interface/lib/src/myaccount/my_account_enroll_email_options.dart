import '../request/request_options.dart';

class MyAccountEnrollEmailOptions implements RequestOptions {
  final String accessToken;
  final String email;

  MyAccountEnrollEmailOptions({
    required this.accessToken,
    required this.email,
  });

  @override
  Map<String, dynamic> toMap() => {
        'accessToken': accessToken,
        'email': email,
      };
}
