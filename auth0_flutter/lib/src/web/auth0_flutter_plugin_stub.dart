import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

class Auth0FlutterPlugin extends AbstractFlutterAuth0Web {
  static void registerWith(final Registrar registrar) {}

  @override
  void slugify(final String str) {
    throw UnsupportedError('slugify is only supported in web platform');
  }
}
