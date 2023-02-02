import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'js_interop.dart';

class Auth0FlutterPlugin extends AbstractFlutterAuth0Web {
  static void registerWith(final Registrar registrar) {
    Auth0FlutterWebPlatform.instance = Auth0FlutterPlugin();
  }

  @override
  void slugify(final String str) {
    // ignore: avoid_print
    print(jsSlugify(str));
  }
}
