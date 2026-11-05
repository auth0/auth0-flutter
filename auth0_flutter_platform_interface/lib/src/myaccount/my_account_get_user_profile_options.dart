import '../request/request_options.dart';

class MyAccountGetUserProfileOptions implements RequestOptions {
  final String accessToken;
  final List<String>? fields;
  final bool includeFields;

  MyAccountGetUserProfileOptions({
    required this.accessToken,
    this.fields,
    this.includeFields = true,
  });

  @override
  Map<String, dynamic> toMap() => {
        'accessToken': accessToken,
        'fields': fields,
        'includeFields': includeFields,
      };
}
