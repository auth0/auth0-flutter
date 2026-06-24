import '../request/request_options.dart';

class AuthPasskeySignupChallengeOptions implements RequestOptions {
  final String? email;
  final String? phoneNumber;
  final String? username;
  final String? name;
  final String? givenName;
  final String? familyName;
  final String? nickname;
  final String? picture;
  final String? connection;
  final String? organization;
  final Map<String, String>? userMetadata;

  AuthPasskeySignupChallengeOptions({
    this.email,
    this.phoneNumber,
    this.username,
    this.name,
    this.givenName,
    this.familyName,
    this.nickname,
    this.picture,
    this.connection,
    this.organization,
    this.userMetadata,
  });

  @override
  Map<String, dynamic> toMap() => {
        'email': email,
        'phoneNumber': phoneNumber,
        'username': username,
        'name': name,
        'givenName': givenName,
        'familyName': familyName,
        'nickname': nickname,
        'picture': picture,
        'connection': connection,
        'organization': organization,
        'userMetadata': userMetadata,
      };
}
