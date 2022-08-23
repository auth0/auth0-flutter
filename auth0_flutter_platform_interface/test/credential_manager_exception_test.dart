import 'package:auth0_flutter_platform_interface/src/credentials-manager/credentials_manager_exception.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CredentialsManagerException', () {
    test('correctly maps from a PlatformException', () async {
      final details = {'details-prop': 'details-value'};
      final platformException = PlatformException(
          code: 'test-code', message: 'test-message', details: details);

      final exception =
          CredentialsManagerException.fromPlatformException(platformException);

      expect(exception.code, 'test-code');
      expect(exception.message, 'test-message');
      expect(exception.details['details-prop'], 'details-value');
    });
  });
}
