@Tags(['browser'])

import 'package:auth0_flutter/src/web/extensions/exchange_token_options_extension.dart';
import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExchangeTokenOptionsExtension', () {
    test('converts ExchangeTokenOptions with required fields only', () {
      final options = ExchangeTokenOptions(
        subjectToken: 'external-token-123',
        subjectTokenType: 'urn:acme:legacy-token',
      );

      final result = options.toInteropExchangeTokenOptions();

      expect(result.subject_token, 'external-token-123');
      expect(result.subject_token_type,
          'urn:acme:legacy-token');
      expect(result.audience, isNull);
      expect(result.scope, isNull);
      expect(result.organization, isNull);
    });

    test('converts ExchangeTokenOptions with all fields', () {
      final options = ExchangeTokenOptions(
        subjectToken: 'external-token-456',
        subjectTokenType: 'urn:example:custom-token',
        audience: 'https://myapi.example.com',
        scopes: {'openid', 'profile', 'email'},
        organizationId: 'org_abc123',
      );

      final result = options.toInteropExchangeTokenOptions();

      expect(result.subject_token, 'external-token-456');
      expect(result.subject_token_type, 'urn:example:custom-token');
      expect(result.audience, 'https://myapi.example.com');
      expect(result.scope, 'openid profile email');
      expect(result.organization, 'org_abc123');
    });

    test('converts empty scopes to null', () {
      final options = ExchangeTokenOptions(
        subjectToken: 'token',
        subjectTokenType: 'type',
        scopes: {},
      );

      final result = options.toInteropExchangeTokenOptions();

      expect(result.scope, isNull);
    });

    test('joins multiple scopes with spaces', () {
      final options = ExchangeTokenOptions(
        subjectToken: 'token',
        subjectTokenType: 'type',
        scopes: {'read:data', 'write:data', 'delete:data'},
      );

      final result = options.toInteropExchangeTokenOptions();

      // Set order is not guaranteed, but all should be present
      expect(result.scope, contains('read:data'));
      expect(result.scope, contains('write:data'));
      expect(result.scope, contains('delete:data'));
      expect(result.scope?.split(' ').length, 3);
    });
  });
}
