import 'dart:js_interop';

/// Mock classes to be used in with fakes created in the auth0_flutter_web_test
/// file. Post  WASM migration the actual classes can't be used for
/// implementation.
/// https://dart.dev/interop/js-interop/mock
/// https://github.com/dart-lang/sdk/issues/55352#issuecomment-2672207215
///

@JSExport()
class Auth0ClientImpl {
  Future<void> handleRedirectCallback([final String? url]) => throw '';
}

@JSExport()
class WebCredentialsImpl {
  String access_token = throw '';
}

