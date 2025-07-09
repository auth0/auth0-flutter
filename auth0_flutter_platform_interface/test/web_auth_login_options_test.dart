import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WebAuthLoginOptions', () {
    test('toMap should include all fields correctly', () {
      final safariViewController = SafariViewController(presentationStyle: SafariViewControllerPresentationStyle.automatic);
      final idTokenValidationConfig = IdTokenValidationConfig(leeway: 0, maxAge: 0, issuer: "issuer");
      final options = WebAuthLoginOptions(
        audience: 'https://myapi.com',
        idTokenValidationConfig: idTokenValidationConfig,
        organizationId: 'org_123',
        invitationUrl: 'https://invite.com',
        redirectUrl: 'com.app://login',
        scopes: {'openid', 'profile'},
        parameters: {'prompt': 'login'},
        useHTTPS: true,
        useEphemeralSession: true,
        scheme: 'demo',
        safariViewController: safariViewController,
        allowedBrowsers: ['chrome', 'firefox'],
      );

      final map = options.toMap();

      expect(map['audience'], 'https://myapi.com');
      expect(map['leeway'], idTokenValidationConfig.leeway);
      expect(map['issuer'], idTokenValidationConfig.issuer);
      expect(map['maxAge'], idTokenValidationConfig.maxAge);
      expect(map['organizationId'], 'org_123');
      expect(map['invitationUrl'], 'https://invite.com');
      expect(map['redirectUrl'], 'com.app://login');
      expect(map['scopes'], ['openid', 'profile']);
      expect(map['parameters'], {'prompt': 'login'});
      expect(map['useHTTPS'], true);
      expect(map['useEphemeralSession'], true);
      expect(map['scheme'], 'demo');
      expect(map['allowedBrowsers'], ['chrome', 'firefox']);
      expect(map['safariViewController'], safariViewController.toMap());
    });

    test('toMap should handle null optional values gracefully', () {
      final options = WebAuthLoginOptions();

      final map = options.toMap();

      expect(map['useHTTPS'], false);
      expect(map['useEphemeralSession'], false);
      expect(map['scheme'], isNull);
      expect(map['safariViewController'], isNull);
      expect(map['allowedBrowsers'], isEmpty);
    });
  });
}
