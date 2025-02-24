import 'package:auth0_flutter_platform_interface/src/account.dart';
import 'package:auth0_flutter_platform_interface/src/auth0_flutter_web_platform.dart';
import 'package:auth0_flutter_platform_interface/src/user_agent.dart';
import 'package:auth0_flutter_platform_interface/src/web/client_options.dart';
import 'package:flutter_test/flutter_test.dart';

class TestAuth0FlutterWeb extends Auth0FlutterWebPlatform {
  TestAuth0FlutterWeb() : super();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Auth0FlutterWebPlatform provides stub implementation', () {
    expect(Auth0FlutterWebPlatform.instance, isA<StubAuth0FlutterWeb>());
  });

  test('Auth0FlutterWebPlatform can set new instance', () {
    final Auth0FlutterWebPlatform impl = TestAuth0FlutterWeb();

    Auth0FlutterWebPlatform.instance = impl;
    expect(Auth0FlutterWebPlatform.instance, impl);
  });

  test('Auth0FlutterWebPlatform appState throws unimplemented error', () {
    expect(
      () => Auth0FlutterWebPlatform.instance.appState,
      throwsUnimplementedError,
    );
  });

  test('Auth0FlutterWebPlatform initialize throws unimplemented error', () {
    final ClientOptions clientOptions = ClientOptions(
      account: const Account('my-domain', 'my-client-id'),
    );
    final UserAgent userAgent = UserAgent(
      name: 'test-user-agent',
      version: '1.0',
    );

    expect(
      () => Auth0FlutterWebPlatform.instance.initialize(
        clientOptions,
        userAgent,
      ),
      throwsUnimplementedError,
    );
  });

  test(
    'Auth0FlutterWebPlatform loginWithRedirect throws unimplemented error',
    () {
      expect(
        () => Auth0FlutterWebPlatform.instance.loginWithRedirect(null),
        throwsUnimplementedError,
      );
    },
  );

  test('Auth0FlutterWebPlatform loginWithPopup throws unimplemented error', () {
    expect(
      () => Auth0FlutterWebPlatform.instance.loginWithPopup(null),
      throwsUnimplementedError,
    );
  });

  test('Auth0FlutterWebPlatform credentials throws unimplemented error', () {
    expect(
      () => Auth0FlutterWebPlatform.instance.credentials(null),
      throwsUnimplementedError,
    );
  });

  test(
    'Auth0FlutterWebPlatform hasValidCredentials throws unimplemented error',
    () {
      expect(
        () => Auth0FlutterWebPlatform.instance.hasValidCredentials(),
        throwsUnimplementedError,
      );
    },
  );

  test('Auth0FlutterWebPlatform logout throws unimplemented error', () {
    expect(
      () => Auth0FlutterWebPlatform.instance.logout(null),
      throwsUnimplementedError,
    );
  });
}
