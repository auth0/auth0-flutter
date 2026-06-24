// ignore_for_file: lines_longer_than_80_chars

import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const account = Account('test-domain', 'test-clientId');
  final userAgent = UserAgent(name: 'test-name', version: 'test-version');

  group('AuthenticationMethodType', () {
    test('toValue maps to the API string', () {
      expect(AuthenticationMethodType.phone.toValue(), 'phone');
      expect(AuthenticationMethodType.pushNotification.toValue(),
          'push-notification');
      expect(AuthenticationMethodType.recoveryCode.toValue(), 'recovery-code');
      expect(AuthenticationMethodType.webAuthnPlatform.toValue(),
          'webauthn-platform');
      expect(AuthenticationMethodType.webAuthnRoaming.toValue(),
          'webauthn-roaming');
    });

    test('fromValue round-trips every value', () {
      for (final type in AuthenticationMethodType.values) {
        expect(AuthenticationMethodType.fromValue(type.toValue()), type);
      }
    });

    test('fromValue returns null for unknown / null', () {
      expect(AuthenticationMethodType.fromValue('nope'), isNull);
      expect(AuthenticationMethodType.fromValue(null), isNull);
    });
  });

  group('options.toMap', () {
    test('get auth methods omits type when null', () {
      final map =
          MyAccountGetAuthMethodsOptions(accessToken: 'token').toMap();
      expect(map['accessToken'], 'token');
      expect(map['type'], isNull);
    });

    test('get auth methods serializes type', () {
      final map = MyAccountGetAuthMethodsOptions(
              accessToken: 'token', type: AuthenticationMethodType.email)
          .toMap();
      expect(map['type'], 'email');
    });

    test('update options serialize name and preferred method', () {
      final map = MyAccountUpdateAuthMethodOptions(
        accessToken: 'token',
        id: 'method-id',
        name: 'My phone',
        preferredAuthenticationMethod: PhoneType.voice,
      ).toMap();
      expect(map['id'], 'method-id');
      expect(map['name'], 'My phone');
      expect(map['preferredAuthenticationMethod'], 'voice');
    });

    test('confirm enrollment options serialize id and authSession', () {
      final map = MyAccountConfirmEnrollmentOptions(
        accessToken: 'token',
        id: 'method-id',
        authSession: 'session',
        factorType: 'recovery-code',
      ).toMap();
      expect(map['id'], 'method-id');
      expect(map['authSession'], 'session');
      expect(map.containsKey('otp'), isFalse);
    });

    test('enroll passkey challenge options omit nulls', () {
      final map =
          MyAccountEnrollPasskeyChallengeOptions(accessToken: 'token').toMap();
      expect(map['accessToken'], 'token');
      expect(map.containsKey('userIdentityId'), isFalse);
      expect(map.containsKey('connection'), isFalse);
    });

    test('enroll passkey challenge options serialize optional values', () {
      final map = MyAccountEnrollPasskeyChallengeOptions(
        accessToken: 'token',
        userIdentityId: 'uid',
        connection: 'db',
      ).toMap();
      expect(map['userIdentityId'], 'uid');
      expect(map['connection'], 'db');
    });

    test('enroll passkey options serialize challenge and credential', () {
      final map = MyAccountEnrollPasskeyOptions(
        accessToken: 'token',
        challenge: const PasskeyEnrollmentChallenge(
          authenticationMethodId: 'method-id',
          authSession: 'session',
          authParamsPublicKey: {'challenge': 'abc', 'rpId': 'example.com'},
        ),
        credential: const PasskeyCredential(
          id: 'cred-id',
          rawId: 'raw-id',
          type: 'public-key',
          response: PasskeyAuthenticatorResponse(
            clientDataJSON: 'client-data',
            attestationObject: 'attestation',
          ),
        ),
      ).toMap();
      expect(map['accessToken'], 'token');
      final challenge = map['challenge'] as Map<String, dynamic>;
      expect(challenge['authenticationMethodId'], 'method-id');
      expect(challenge['authSession'], 'session');
      final credential = map['credential'] as Map<String, dynamic>;
      expect(credential['id'], 'cred-id');
      expect((credential['response'] as Map)['attestationObject'],
          'attestation');
    });
  });

  group('PasskeyEnrollmentChallenge', () {
    test('fromMap / toMap round-trip', () {
      const map = {
        'authenticationMethodId': 'method-id',
        'authSession': 'session',
        'authParamsPublicKey': {'challenge': 'abc', 'rpId': 'example.com'},
      };
      final challenge = PasskeyEnrollmentChallenge.fromMap(map);
      expect(challenge.authenticationMethodId, 'method-id');
      expect(challenge.authSession, 'session');
      expect(challenge.authParamsPublicKey['rpId'], 'example.com');
      expect(challenge.toMap(), map);
    });
  });

  group('MyAccountPasskeyAuthenticationMethod', () {
    test('fromMap parses passkey-specific fields', () {
      final method = MyAccountPasskeyAuthenticationMethod.fromMap(const {
        'id': 'passkey|1',
        'type': 'passkey',
        'identity_user_id': 'uid',
        'user_agent': 'agent',
        'key_id': 'key-id',
        'public_key': 'pub',
        'user_handle': 'handle',
        'credential_device_type': 'multi_device',
        'credential_backed_up': true,
        'aaguid': 'aaguid',
        'relying_party_id': 'example.com',
        'transports': ['internal'],
        'created_at': '2024-01-01T00:00:00.000Z',
        'usage': ['mfa'],
      });
      expect(method.id, 'passkey|1');
      expect(method.type, 'passkey');
      expect(method.userIdentityId, 'uid');
      expect(method.credentialDeviceType, 'multi_device');
      expect(method.credentialBackedUp, true);
      expect(method.aaguid, 'aaguid');
      expect(method.relyingPartyId, 'example.com');
      expect(method.transports, ['internal']);
      expect(method.usage, ['mfa']);
      expect(method.createdAt, DateTime.parse('2024-01-01T00:00:00.000Z'));
    });
  });

  group('ApiRequest useDPoP', () {
    test('defaults to false and is included in the map', () {
      final request = ApiRequest<MyAccountGetAuthMethodsOptions>(
        account: account,
        userAgent: userAgent,
        options: MyAccountGetAuthMethodsOptions(accessToken: 'token'),
      );
      expect(request.toMap()['useDPoP'], false);
    });

    test('propagates true into the map', () {
      final request = ApiRequest<MyAccountGetAuthMethodsOptions>(
        account: account,
        userAgent: userAgent,
        options: MyAccountGetAuthMethodsOptions(accessToken: 'token'),
        useDPoP: true,
      );
      expect(request.toMap()['useDPoP'], true);
    });
  });

  group('MethodChannelAuth0FlutterMyAccount', () {
    const channel = MethodChannel('auth0.com/auth0_flutter/my_account');
    final platform = MethodChannelAuth0FlutterMyAccount();
    final log = <MethodCall>[];

    const methodMap = {
      'id': 'method-id',
      'type': 'phone',
      'confirmed': true,
    };

    setUp(() {
      log.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (final call) async {
        log.add(call);
        return methodMap;
      });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('confirmEnrollment invokes the correct method and parses result',
        () async {
      final method = await platform.confirmEnrollment(
        ApiRequest<MyAccountConfirmEnrollmentOptions>(
          account: account,
          userAgent: userAgent,
          options: MyAccountConfirmEnrollmentOptions(
              accessToken: 'token', id: 'method-id', authSession: 'session', factorType: 'recovery-code'),
        ),
      );

      expect(log.single.method, 'myAccount#confirmEnrollment');
      expect(method.id, 'method-id');
      expect(method.confirmed, true);
    });

    test('updateAuthenticationMethod invokes the correct method', () async {
      final method = await platform.updateAuthenticationMethod(
        ApiRequest<MyAccountUpdateAuthMethodOptions>(
          account: account,
          userAgent: userAgent,
          options: MyAccountUpdateAuthMethodOptions(
              accessToken: 'token', id: 'method-id', name: 'New name'),
        ),
      );

      expect(log.single.method, 'myAccount#updateAuthenticationMethod');
      expect((log.single.arguments as Map)['name'], 'New name');
      expect(method.id, 'method-id');
    });

    test('enrollPasskeyChallenge invokes the correct method and parses result',
        () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (final call) async {
        log.add(call);
        return {
          'authenticationMethodId': 'method-id',
          'authSession': 'session',
          'authParamsPublicKey': {'challenge': 'abc', 'rpId': 'example.com'},
        };
      });

      final challenge = await platform.enrollPasskeyChallenge(
        ApiRequest<MyAccountEnrollPasskeyChallengeOptions>(
          account: account,
          userAgent: userAgent,
          options: MyAccountEnrollPasskeyChallengeOptions(
              accessToken: 'token', connection: 'db'),
        ),
      );

      expect(log.single.method, 'myAccount#enrollPasskeyChallenge');
      expect((log.single.arguments as Map)['connection'], 'db');
      expect(challenge.authenticationMethodId, 'method-id');
      expect(challenge.authParamsPublicKey['rpId'], 'example.com');
    });

    test('enrollPasskey invokes the correct method and parses result',
        () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (final call) async {
        log.add(call);
        return {
          'id': 'passkey|1',
          'type': 'passkey',
          'relying_party_id': 'example.com',
        };
      });

      final method = await platform.enrollPasskey(
        ApiRequest<MyAccountEnrollPasskeyOptions>(
          account: account,
          userAgent: userAgent,
          options: MyAccountEnrollPasskeyOptions(
            accessToken: 'token',
            challenge: const PasskeyEnrollmentChallenge(
              authenticationMethodId: 'method-id',
              authSession: 'session',
              authParamsPublicKey: {'challenge': 'abc'},
            ),
            credential: const PasskeyCredential(
              id: 'cred-id',
              rawId: 'raw-id',
              type: 'public-key',
              response: PasskeyAuthenticatorResponse(
                clientDataJSON: 'client-data',
                attestationObject: 'attestation',
              ),
            ),
          ),
        ),
      );

      expect(log.single.method, 'myAccount#enrollPasskey');
      expect(method.id, 'passkey|1');
      expect(method.relyingPartyId, 'example.com');
    });

    test('getAuthenticationMethods forwards the type filter', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (final call) async {
        log.add(call);
        return [methodMap];
      });

      await platform.getAuthenticationMethods(
        ApiRequest<MyAccountGetAuthMethodsOptions>(
          account: account,
          userAgent: userAgent,
          options: MyAccountGetAuthMethodsOptions(
              accessToken: 'token', type: AuthenticationMethodType.phone),
        ),
      );

      expect(log.single.method, 'myAccount#getAuthenticationMethods');
      expect((log.single.arguments as Map)['type'], 'phone');
    });
  });
}
