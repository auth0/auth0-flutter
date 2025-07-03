@Tags(['browser'])

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

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

  group('stripNulls', () {
    test('removes null values from an object', () {
      final objectWithNulls = JSObject();

      objectWithNulls.setProperty('someField'.toJS, true.toJS);
      objectWithNulls.setProperty('someNullField'.toJS, null);

      final JSObject output = JsInteropUtils.stripNulls(objectWithNulls);

      expect(
        (output.getProperty('someField'.toJS) as JSBoolean).toDart,
        isTrue,
      );

      expect(output.has('someNullField'), isFalse);
    });
  });
}
