import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthCustomTokenExchangeOptions', () {
    test('creates options with required parameters', () {
      final options = AuthCustomTokenExchangeOptions(
        subjectToken: 'existing-token',
        subjectTokenType: 'http://acme.com/legacy-token',
      );

      expect(options.subjectToken, 'existing-token');
      expect(options.subjectTokenType, 'http://acme.com/legacy-token');
      expect(options.audience, isNull);
      expect(options.scopes, isEmpty);
      expect(options.organization, isNull);
      expect(options.parameters, isEmpty);
    });

    test('creates options with all parameters', () {
      final options = AuthCustomTokenExchangeOptions(
        subjectToken: 'existing-token',
        subjectTokenType: 'http://acme.com/legacy-token',
        audience: 'https://example.com/api',
        scopes: {'openid', 'profile', 'email'},
        organization: 'org_abc123',
        parameters: {'test': 'test-123'},
      );

      expect(options.subjectToken, 'existing-token');
      expect(options.subjectTokenType, 'http://acme.com/legacy-token');
      expect(options.audience, 'https://example.com/api');
      expect(options.scopes, {'openid', 'profile', 'email'});
      expect(options.organization, 'org_abc123');
      expect(options.parameters, {'test': 'test-123'});
    });

    test('toMap includes all properties', () {
      final options = AuthCustomTokenExchangeOptions(
        subjectToken: 'existing-token',
        subjectTokenType: 'http://acme.com/legacy-token',
        audience: 'https://example.com/api',
        scopes: {'openid', 'profile', 'email'},
        organization: 'org_abc123',
        parameters: {'test': 'test-123'},
      );

      final map = options.toMap();

      expect(map['subjectToken'], 'existing-token');
      expect(map['subjectTokenType'], 'http://acme.com/legacy-token');
      expect(map['audience'], 'https://example.com/api');
      expect(map['scopes'], ['openid', 'profile', 'email']);
      expect(map['organization'], 'org_abc123');
      expect(map['parameters'], {'test': 'test-123'});
    });

    test('toMap excludes null audience', () {
      final options = AuthCustomTokenExchangeOptions(
        subjectToken: 'existing-token',
        subjectTokenType: 'http://acme.com/legacy-token',
      );

      final map = options.toMap();

      expect(map.containsKey('audience'), isFalse);
    });

    test('toMap excludes null organization', () {
      final options = AuthCustomTokenExchangeOptions(
        subjectToken: 'existing-token',
        subjectTokenType: 'http://acme.com/legacy-token',
      );

      final map = options.toMap();

      expect(map.containsKey('organization'), isFalse);
    });

    test('toMap includes organization when provided', () {
      final options = AuthCustomTokenExchangeOptions(
        subjectToken: 'existing-token',
        subjectTokenType: 'http://acme.com/legacy-token',
        organization: 'org_abc123',
      );

      final map = options.toMap();

      expect(map['organization'], 'org_abc123');
      expect(map.containsKey('organization'), isTrue);
    });

    test('toMap includes empty scopes and parameters', () {
      final options = AuthCustomTokenExchangeOptions(
        subjectToken: 'existing-token',
        subjectTokenType: 'http://acme.com/legacy-token',
        scopes: {},
        parameters: {},
      );

      final map = options.toMap();

      expect(map['scopes'], isEmpty);
      expect(map['parameters'], isEmpty);
    });
  });
}
