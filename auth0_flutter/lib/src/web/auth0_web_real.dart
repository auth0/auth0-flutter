import 'auth0_web.dart';
import 'interop_web.dart';

class Auth0Web implements AbstractAuth0Web {
  @override
  void slugify(final String str) {
    // ignore: avoid_print
    print(jsSlugify(str));
  }
}
