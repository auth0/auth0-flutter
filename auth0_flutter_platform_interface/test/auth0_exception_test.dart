import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';
import 'package:auth0_flutter_platform_interface/src/auth0_exception.dart';
import 'package:flutter_test/flutter_test.dart';

class TestAuth0Exception extends Auth0Exception {

  TestAuth0Exception(final String code, final String message,
      final Map<String, dynamic> details)
      : super(code, message, details);

  TestAuth0Exception.unknown(final String message) : super.unknown(message);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Auth0Exception', () {
    test('correctly shows the string representation', () async {
      final details = {'details-prop': 'details-value'};
      final exception = TestAuth0Exception('test-code', 'test-message', details);

      expect(exception.toString(), 'test-code: test-message');
    });

    test('correctly sets the code when calling unknown', () async {
      final exception = TestAuth0Exception.unknown('test-message');

      expect(exception.code, 'UNKNOWN');
      expect(exception.toString(), 'UNKNOWN: test-message');
    });
  });
}
