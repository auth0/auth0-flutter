@Tags(['browser'])

import 'package:auth0_flutter/src/web/js_interop.dart';
import 'package:auth0_flutter/src/web/js_interop_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('addCustomParameters', () {
    test('adds arbitrary parameters to an object', () {
      final object = AuthorizationParams(audience: 'test');

      final output = JsInteropUtils.addCustomParams(
          object, {'custom_param': 'custom_value'});

      expect(output, isNotNull);
      expect(output.audience, 'test');
      expect((output as dynamic).custom_param, 'custom_value');
    });

    test('does not add parameters that are null', () {
      final object = AuthorizationParams();

      final output =
          JsInteropUtils.addCustomParams(object, {'custom_param': null});

      expect(output, isNotNull);
      expect((output as dynamic).custom_param, null);
    });
  });
}
