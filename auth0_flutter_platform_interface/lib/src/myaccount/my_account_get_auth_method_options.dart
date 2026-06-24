import '../request/request_options.dart';

class MyAccountGetAuthMethodOptions implements RequestOptions {
  final String accessToken;
  final String id;

  MyAccountGetAuthMethodOptions({
    required this.accessToken,
    required this.id,
  });

  @override
  Map<String, dynamic> toMap() => {
        'accessToken': accessToken,
        'id': id,
      };
}
