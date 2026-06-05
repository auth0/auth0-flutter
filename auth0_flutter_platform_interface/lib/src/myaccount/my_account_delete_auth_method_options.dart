import '../request/request_options.dart';

class MyAccountDeleteAuthMethodOptions implements RequestOptions {
  final String accessToken;
  final String id;

  MyAccountDeleteAuthMethodOptions({
    required this.accessToken,
    required this.id,
  });

  @override
  Map<String, dynamic> toMap() => {
        'accessToken': accessToken,
        'id': id,
      };
}
