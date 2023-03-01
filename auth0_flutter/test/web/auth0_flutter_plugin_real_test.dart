@Tags(['browser'])
@TestOn('browser')

// import 'dart:js';

import 'package:auth0_flutter/auth0_flutter_web.dart';
import 'package:auth0_flutter/src/web/auth0_flutter_plugin_real.dart';
import 'package:auth0_flutter/src/web/js_interop.dart';
import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'auth0_flutter_plugin_real_test.mocks.dart';

@GenerateNiceMocks([MockSpec<Auth0Client>()])
void main() {
  final client = MockAuth0Client();
  final auth0 = Auth0Web('test-domain', 'test-client-id');
  Auth0FlutterWebPlatform.instance = Auth0FlutterPlugin(client: client);

  test('onLoad', () async {
    when(client.getTokenSilently(any))
        .thenAnswer((final r) async => Future.value(WebCredentials()));

    when(client.checkSession()).thenAnswer((final _) => Future.value());

    expect(await auth0.onLoad(), null);

    verify(client.checkSession());
  });
}
