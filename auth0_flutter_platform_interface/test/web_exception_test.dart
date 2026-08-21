import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WebException.passkeyError', () {
    test('sets the passkey code and carries the error in details', () {
      final exception = WebException.passkeyError(
          'passkey_not_supported', 'Passkeys are not supported');

      expect(exception.code, 'PASSKEY_ERROR');
      expect(exception.message, 'Passkeys are not supported');
      expect(exception.details['code'], 'passkey_not_supported');
    });

    test('merges additional details alongside the error code', () {
      final exception = WebException.passkeyError('passkey_register_error',
          'Registration failed', {'cause': 'aborted'});

      expect(exception.code, 'PASSKEY_ERROR');
      expect(exception.details['code'], 'passkey_register_error');
      expect(exception.details['cause'], 'aborted');
    });

    test('error stays authoritative when details carries its own code', () {
      final exception = WebException.passkeyError(
          'passkey_register_error', 'Registration failed', {'code': 'ignored'});

      expect(exception.details['code'], 'passkey_register_error');
    });

    test('null details yields details containing only the code', () {
      final exception =
          WebException.passkeyError('passkey_error', 'Unknown error');

      expect(exception.details, {'code': 'passkey_error'});
    });
  });
}
