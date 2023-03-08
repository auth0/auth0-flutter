@Tags(['browser'])

import 'package:auth0_flutter/auth0_flutter_web.dart';
import 'package:auth0_flutter/src/web/auth0_flutter_plugin_real.dart';
import 'package:auth0_flutter/src/web/auth0_flutter_web_platform_proxy.dart';
import 'package:auth0_flutter/src/web/js_interop.dart';
import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'auth0_fluter_web_test.mocks.dart';

@GenerateMocks([Auth0FlutterWebClientProxy])
void main() {
  final auth0 = Auth0Web('test-domain', 'test-client-id');
  final mockClientProxy = MockAuth0FlutterWebClientProxy();
  final jwt = JWT({'sub': 'auth0:1'}).sign(SecretKey('secret'));

  setUp(() {
    final plugin = Auth0FlutterPlugin();
    plugin.clientProxy = mockClientProxy;
    Auth0FlutterWebPlatform.instance = plugin;
    reset(mockClientProxy);
  });

  test('onLoad is called without authenticated user and no callback', () async {
    when(mockClientProxy.isAuthenticated())
        .thenAnswer((final _) => Future.value(false));

    await auth0.onLoad();
  });

  test('onLoad is called with an authenticated user and no callback', () async {
    when(mockClientProxy.isAuthenticated()).thenAnswer((final _) async => true);

    when(mockClientProxy.getTokenSilently(any)).thenAnswer((final _) =>
        Future.value(WebCredentials(
            access_token: jwt,
            id_token: jwt,
            refresh_token: jwt,
            scope: 'openid read_messages',
            expires_in: 0)));

    final result = await auth0.onLoad();

    expect(result?.accessToken, jwt);
    expect(result?.idToken, jwt);
    expect(result?.refreshToken, jwt);
    expect(result?.user.sub, 'auth0:1');
    expect(result?.scopes, {'openid', 'read_messages'});
  });
}
