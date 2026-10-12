import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CustomTabsOptions', () {
    test('toMap includes useTrustedWebActivity and useAuthTab', () {
      const options = CustomTabsOptions(
        useTrustedWebActivity: true,
        useAuthTab: true,
      );

      final map = options.toMap();

      expect(map['useTrustedWebActivity'], true);
      expect(map['useAuthTab'], true);
    });

    test('useTrustedWebActivity and useAuthTab default to null', () {
      final map = const CustomTabsOptions().toMap();

      expect(map['useTrustedWebActivity'], isNull);
      expect(map['useAuthTab'], isNull);
    });

    test('is passed through WebAuthLoginOptions and WebAuthLogoutOptions', () {
      const tabs = CustomTabsOptions(useAuthTab: true);

      final login = WebAuthLoginOptions(customTabsOptions: tabs).toMap();
      final logout = WebAuthLogoutOptions(customTabsOptions: tabs).toMap();

      expect((login['customTabsOptions'] as Map)['useAuthTab'], true);
      expect((logout['customTabsOptions'] as Map)['useAuthTab'], true);
    });
  });
}
