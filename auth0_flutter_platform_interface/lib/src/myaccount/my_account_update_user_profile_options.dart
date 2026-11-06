import '../request/request_options.dart';

class MyAccountUpdateUserProfileOptions implements RequestOptions {
  final String accessToken;
  final String? givenName;
  final String? familyName;
  final String? name;
  final String? nickname;
  final String? picture;

  MyAccountUpdateUserProfileOptions({
    required this.accessToken,
    this.givenName,
    this.familyName,
    this.name,
    this.nickname,
    this.picture,
  });

  @override
  Map<String, dynamic> toMap() => {
        'accessToken': accessToken,
        'givenName': givenName,
        'familyName': familyName,
        'name': name,
        'nickname': nickname,
        'picture': picture,
      };
}
