@Tags(['browser'])

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:auth0_flutter/src/web/extensions/passkey_extensions.dart';
import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

String? _readString(JSObject object, String key) =>
    (object.getProperty(key.toJS) as JSString?)?.toDart;

void main() {
  group('PasskeySignupChallengeOptionsExtension userMetadata', () {
    test('null userMetadata is forwarded as null', () {
      final options = WebPasskeySignupChallengeOptions(email: 'a@b.com');

      final result = options.toInterop();

      expect(result.userMetadata, isNull);
    });

    test('populated userMetadata is jsified into a JSObject', () {
      final options = WebPasskeySignupChallengeOptions(
        userMetadata: {'plan': 'gold', 'referrer': 'newsletter'},
      );

      final result = options.toInterop();
      final metadata = result.userMetadata;

      expect(metadata, isA<JSObject>());
      expect(_readString(metadata!, 'plan'), 'gold');
      expect(_readString(metadata, 'referrer'), 'newsletter');
    });

    test('empty userMetadata is jsified into an empty JSObject', () {
      final options =
          WebPasskeySignupChallengeOptions(userMetadata: <String, String>{});

      final result = options.toInterop();

      expect(result.userMetadata, isA<JSObject>());
      expect(result.userMetadata!.has('plan'), isFalse);
    });

    test('keys that are not valid JS identifiers survive the conversion', () {
      final options = WebPasskeySignupChallengeOptions(
        userMetadata: {
          'app.metadata': 'nested-looking-key',
          '': 'empty-key',
          'ünïcode': 'ünïcode-value',
          '123': 'numeric-key',
        },
      );

      final result = options.toInterop();
      final metadata = result.userMetadata;

      expect(metadata, isA<JSObject>());
      expect(_readString(metadata!, 'app.metadata'), 'nested-looking-key');
      expect(_readString(metadata, ''), 'empty-key');
      expect(_readString(metadata, 'ünïcode'), 'ünïcode-value');
      expect(_readString(metadata, '123'), 'numeric-key');
    });

    test('values that shadow JS internals are kept as plain strings', () {
      final options = WebPasskeySignupChallengeOptions(
        userMetadata: {'toString': 'not-a-function', 'prototype': 'value'},
      );

      final result = options.toInterop();
      final metadata = result.userMetadata;

      expect(metadata, isA<JSObject>());
      expect(_readString(metadata!, 'toString'), 'not-a-function');
      expect(_readString(metadata, 'prototype'), 'value');
    });

    test('a cast view holding a non-string value yields null, not a throw', () {
      // A caller can hand us a `Map<String, String>` obtained from `cast()`
      // over dynamic JSON; its values are only type-checked on read, so the
      // conversion blows up at runtime rather than at compile time.
      final options = WebPasskeySignupChallengeOptions(
        email: 'user@example.com',
        userMetadata: <String, dynamic>{
          'plan': 'gold',
          'seats': 3,
        }.cast<String, String>(),
      );

      final result = options.toInterop();

      expect(result.userMetadata, isNull);
      // The rest of the options still convert normally.
      expect(result.email, 'user@example.com');
    });

    test('a cast view holding a non-jsifiable object yields null', () {
      final options = WebPasskeySignupChallengeOptions(
        userMetadata: <String, dynamic>{
          'session': Object(),
        }.cast<String, String>(),
      );

      expect(options.toInterop().userMetadata, isNull);
    });

    test('other signup fields are unaffected by userMetadata conversion', () {
      final options = WebPasskeySignupChallengeOptions(
        email: 'user@example.com',
        phoneNumber: '+15550100',
        username: 'user',
        name: 'Test User',
        givenName: 'Test',
        familyName: 'User',
        nickname: 'tester',
        picture: 'https://example.com/pic.png',
        connection: 'Username-Password-Authentication',
        organization: 'org_123',
        userMetadata: {'plan': 'gold'},
      );

      final result = options.toInterop();

      expect(result.email, 'user@example.com');
      expect(result.phoneNumber, '+15550100');
      expect(result.username, 'user');
      expect(result.name, 'Test User');
      expect(result.givenName, 'Test');
      expect(result.familyName, 'User');
      expect(result.nickname, 'tester');
      expect(result.picture, 'https://example.com/pic.png');
      expect(result.realm, 'Username-Password-Authentication');
      expect(result.organization, 'org_123');
      expect(result.userMetadata, isA<JSObject>());
    });
  });
}
