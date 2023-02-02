import 'auth0_web.dart';

class Auth0Web implements AbstractAuth0Web {
  @override
  void slugify(final String str) {
    throw UnsupportedError('slugify is only supported in web platform');
  }
}
