@Tags(['browser'])

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:auth0_flutter/src/web/extensions/client_options_extensions.dart';
import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

bool? _readBool(final JSObject object, final String key) =>
    (object.getProperty(key.toJS) as JSBoolean?)?.toDart;

void main() {
  final userAgent = UserAgent(name: 'auth0-flutter', version: '1.0.0');
  const account = Account('test-domain', 'test-client-id');

  group('ClientOptionsExtension MRRT', () {
    test('useMrrt is forwarded and auto-enables refresh tokens', () {
      final options = ClientOptions(account: account, useMrrt: true);

      final result = options.toAuth0ClientOptions(userAgent) as JSObject;

      expect(_readBool(result, 'useMrrt'), true);
      // MRRT requires refresh tokens, so they are implicitly enabled.
      expect(_readBool(result, 'useRefreshTokens'), true);
    });

    test('useMrrt forces refresh tokens on even when set to false', () {
      final options = ClientOptions(
          account: account, useMrrt: true, useRefreshTokens: false);

      final result = options.toAuth0ClientOptions(userAgent) as JSObject;

      expect(_readBool(result, 'useMrrt'), true);
      expect(_readBool(result, 'useRefreshTokens'), true);
    });

    test('useMrrt is not enabled by default', () {
      final options = ClientOptions(account: account);

      final result = options.toAuth0ClientOptions(userAgent) as JSObject;

      expect(_readBool(result, 'useMrrt'), isNull);
    });
  });
}
