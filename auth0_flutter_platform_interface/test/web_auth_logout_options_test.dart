import 'package:test/test.dart';
import 'package:auth0_flutter_platform_interface/src/web-auth/web_auth_logout_options.dart';

void main() {
  group('WebAuthLogoutOptions', () {
    test('toMap includes all fields correctly', () {
      final options = WebAuthLogoutOptions(
        useHTTPS: true,
        returnTo: 'https://example.com/logout',
        scheme: 'custom-scheme',
        federated: true,
      );
      final map = options.toMap();
      expect(map['useHTTPS'], true);
      expect(map['returnTo'], 'https://example.com/logout');
      expect(map['scheme'], 'custom-scheme');
      expect(map['federated'], true);
    });

    test('toMap handles null optional values', () {
      final options = WebAuthLogoutOptions();
      final map = options.toMap();
      expect(map['useHTTPS'], false);
      expect(map['returnTo'], null);
      expect(map['scheme'], null);
      expect(map['federated'], null);
    });
  });
}
