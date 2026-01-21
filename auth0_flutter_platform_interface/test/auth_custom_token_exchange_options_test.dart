import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthCustomTokenExchangeOptions', () {
    test('creates options with required parameters', () {
      const options =  AuthCustomTokenExchangeOptions(
        subjectToken: 'existing-token',
        subjectTokenType: 'http://acme.com/legacy-token',
      );

      expect(options.subjectToken, 'existing-token');
      expect(options.subjectTokenType, 'http://acme.com/legacy-token');
      expect(options.audience, isNull);
      expect(options.scopes, isEmpty);
      expect(options.organization, isNull);
    });

    test('creates options with all parameters', () {
      const options =  AuthCustomTokenExchangeOptions(
        subjectToken: 'existing-token',
        subjectTokenType: 'http://acme.com/legacy-token',
        audience: 'https://example.com/api',
        scopes: {'openid', 'profile', 'email'},
        organization: 'org_abc123',
      );

      expect(options.subjectToken, 'existing-token');
      expect(options.subjectTokenType, 'http://acme.com/legacy-token');
      expect(options.audience, 'https://example.com/api');
      expect(options.scopes, {'openid', 'profile', 'email'});
      expect(options.organization, 'org_abc123');
    });

    test('toMap includes all properties', () {
      const options =  AuthCustomTokenExchangeOptions(
        subjectToken: 'existing-token',
        subjectTokenType: 'http://acme.com/legacy-token',
        audience: 'https://example.com/api',
        scopes: {'openid', 'profile', 'email'},
        organization: 'org_abc123',
      );

      final map = options.toMap();

      expect(map['subjectToken'], 'existing-token');
      expect(map['subjectTokenType'], 'http://acme.com/legacy-token');
      expect(map['audience'], 'https://example.com/api');
      expect(map['scopes'], ['openid', 'profile', 'email']);
      expect(map['organization'], 'org_abc123');
    });

    test('toMap excludes null audience', () {
      const options =  AuthCustomTokenExchangeOptions(
        subjectToken: 'existing-token',
        subjectTokenType: 'http://acme.com/legacy-token',
      );

      final map = options.toMap();

      expect(map.containsKey('audience'), isFalse);
    });

    test('toMap excludes null organization', () {
      const options =  AuthCustomTokenExchangeOptions(
        subjectToken: 'existing-token',
        subjectTokenType: 'http://acme.com/legacy-token',
      );

      final map = options.toMap();

      expect(map.containsKey('organization'), isFalse);
    });

    test('toMap includes organization when provided', () {
      const options =  AuthCustomTokenExchangeOptions(
        subjectToken: 'existing-token',
        subjectTokenType: 'http://acme.com/legacy-token',
        organization: 'org_abc123',
      );

      final map = options.toMap();

      expect(map['organization'], 'org_abc123');
      expect(map.containsKey('organization'), isTrue);
    });

    test('toMap includes empty scopes', () {
      const options =  AuthCustomTokenExchangeOptions(
        subjectToken: 'existing-token',
        subjectTokenType: 'http://acme.com/legacy-token'
      );

      final map = options.toMap();

      expect(map['scopes'], isEmpty);
    });
  });
}
