import 'credentials.dart';
import 'user_profile.dart';

class CredentialsWithUserProfile extends Credentials {
  late UserProfile userProfile;

  CredentialsWithUserProfile.fromMap(final Map<dynamic, dynamic> result)
      : super.fromMap(result) {
    userProfile = Map<String, dynamic>.from(
        result['userProfile'] as Map<dynamic, dynamic>);
  }
}
