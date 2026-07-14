// ignore_for_file: lines_longer_than_80_chars

import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const account = Account('test-domain', 'test-clientId');
  final userAgent = UserAgent(name: 'test-name', version: 'test-version');

  ApiRequest<TOptions> request<TOptions extends RequestOptions>(
          final TOptions options) =>
      ApiRequest<TOptions>(
          account: account, options: options, userAgent: userAgent);

  group('options.toMap', () {
    test('get authenticators serializes token and factors', () {
      final map = MfaGetAuthenticatorsOptions(
              mfaToken: 'mfa-token', factorsAllowed: ['otp', 'oob'])
          .toMap();
      expect(map['mfaToken'], 'mfa-token');
      expect(map['factorsAllowed'], ['otp', 'oob']);
    });

    test('get authenticators forwards an empty factors list unchanged', () {
      // The native SDKs reject an empty list with `invalid_request`; the bridge
      // must forward it verbatim rather than substituting a default, so that
      // native validation is the single source of truth.
      final map = MfaGetAuthenticatorsOptions(
              mfaToken: 'mfa-token', factorsAllowed: const [])
          .toMap();
      expect(map['factorsAllowed'], isEmpty);
    });

    test('enroll phone serializes phoneNumber', () {
      final map = MfaEnrollPhoneOptions(
        mfaToken: 'mfa-token',
        phoneNumber: '+1234567890',
      ).toMap();
      expect(map['mfaToken'], 'mfa-token');
      expect(map['phoneNumber'], '+1234567890');
    });

    test('enroll email serializes email', () {
      final map =
          MfaEnrollEmailOptions(mfaToken: 'mfa-token', email: 'a@b.com')
              .toMap();
      expect(map['email'], 'a@b.com');
    });

    test('challenge serializes authenticatorId', () {
      final map = MfaChallengeOptions(
              mfaToken: 'mfa-token', authenticatorId: 'sms|abc')
          .toMap();
      expect(map['authenticatorId'], 'sms|abc');
    });

    test('verify serializes grant type and otp', () {
      final map = MfaVerifyOptions(
        mfaToken: 'mfa-token',
        grantType: MfaVerifyGrantType.otp,
        otp: '123456',
      ).toMap();
      expect(map['grantType'], 'otp');
      expect(map['otp'], '123456');
    });

    test('verify serializes scopes and audience when provided', () {
      final map = MfaVerifyOptions(
        mfaToken: 'mfa-token',
        grantType: MfaVerifyGrantType.otp,
        otp: '123456',
        scopes: {'openid', 'profile'},
        audience: 'https://my-api.example.com',
      ).toMap();
      expect(map['scopes'], ['openid', 'profile']);
      expect(map['audience'], 'https://my-api.example.com');
    });

    test('verify omits audience and sends empty scopes by default', () {
      final map = MfaVerifyOptions(
        mfaToken: 'mfa-token',
        grantType: MfaVerifyGrantType.otp,
        otp: '123456',
      ).toMap();
      expect(map['scopes'], isEmpty);
      expect(map.containsKey('audience'), isFalse);
    });

    test('verify serializes oob grant with binding code', () {
      final map = MfaVerifyOptions(
        mfaToken: 'mfa-token',
        grantType: MfaVerifyGrantType.oob,
        oobCode: 'oob-code',
        bindingCode: '000111',
      ).toMap();
      expect(map['grantType'], 'oob');
      expect(map['oobCode'], 'oob-code');
      expect(map['bindingCode'], '000111');
    });

    test('verify serializes recovery code grant', () {
      final map = MfaVerifyOptions(
        mfaToken: 'mfa-token',
        grantType: MfaVerifyGrantType.recoveryCode,
        recoveryCode: 'ABCD',
      ).toMap();
      expect(map['grantType'], 'recovery_code');
      expect(map['recoveryCode'], 'ABCD');
    });
  });

  group('MfaAuthenticator', () {
    test('fromMap / toMap round-trip', () {
      const map = {
        'id': 'sms|dev_1',
        'type': 'phone',
        'authenticator_type': 'oob',
        'active': true,
        'oob_channel': 'sms',
        'name': '****4761',
      };
      final authenticator =
          MfaAuthenticator.fromMap(Map<String, dynamic>.from(map));
      expect(authenticator.id, 'sms|dev_1');
      expect(authenticator.type, 'phone');
      expect(authenticator.authenticatorType, 'oob');
      expect(authenticator.active, true);
      expect(authenticator.oobChannel, 'sms');
      expect(authenticator.name, '****4761');
      expect(authenticator.toMap(), map);
    });
  });

  group('MfaChallenge', () {
    test('fromMap parses oob challenge', () {
      final challenge = MfaChallenge.fromMap(const {
        'challenge_type': 'oob',
        'oob_code': 'code',
        'binding_method': 'prompt',
      });
      expect(challenge.challengeType, 'oob');
      expect(challenge.oobCode, 'code');
      expect(challenge.bindingMethod, 'prompt');
    });
  });

  group('MfaEnrollmentChallenge', () {
    test('fromMap parses totp fields', () {
      final challenge = MfaEnrollmentChallenge.fromMap(const {
        'authenticator_type': 'otp',
        'totp_secret': 'SECRET',
        'barcode_uri': 'otpauth://totp/...',
        'recovery_codes': ['r1', 'r2'],
      });
      expect(challenge.authenticatorType, 'otp');
      expect(challenge.totpSecret, 'SECRET');
      expect(challenge.barcodeUri, 'otpauth://totp/...');
      expect(challenge.recoveryCodes, ['r1', 'r2']);
    });

    test('fromMap parses oob fields', () {
      final challenge = MfaEnrollmentChallenge.fromMap(const {
        'authenticator_type': 'oob',
        'oob_channel': 'sms',
        'oob_code': 'oob-code',
        'binding_method': 'prompt',
      });
      expect(challenge.oobChannel, 'sms');
      expect(challenge.oobCode, 'oob-code');
      expect(challenge.bindingMethod, 'prompt');
    });
  });

  group('MfaRequirements', () {
    test('parses challenge and enroll factors', () {
      final requirements = MfaRequirements.fromMap(const {
        'challenge': [
          {'type': 'otp'},
          {'type': 'email'},
        ],
        'enroll': [
          {'type': 'push-notification'},
        ],
      });
      expect(requirements.challenge.map((final f) => f.type),
          containsAll(['otp', 'email']));
      expect(requirements.enroll.single.type, 'push-notification');
    });

    test('defaults to empty lists when missing', () {
      final requirements = MfaRequirements.fromMap(const {});
      expect(requirements.challenge, isEmpty);
      expect(requirements.enroll, isEmpty);
    });
  });

  group('MethodChannelAuth0FlutterMfa', () {
    const channel = MethodChannel('auth0.com/auth0_flutter/mfa');
    final platform = MethodChannelAuth0FlutterMfa();
    final log = <MethodCall>[];

    setUp(log.clear);

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    void mock(final Object? response) {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (final call) async {
        log.add(call);
        return response;
      });
    }

    test('getAuthenticators invokes the correct method and parses result',
        () async {
      mock([
        {'id': 'sms|1', 'authenticator_type': 'oob', 'active': true},
      ]);

      final result = await platform.getAuthenticators(request(
          MfaGetAuthenticatorsOptions(
              mfaToken: 'mfa-token', factorsAllowed: ['oob'])));

      expect(log.single.method, 'mfa#getAuthenticators');
      expect((log.single.arguments as Map)['factorsAllowed'], ['oob']);
      expect(result.single.id, 'sms|1');
    });

    test('enrollTotp invokes the correct method and parses result', () async {
      mock({'authenticator_type': 'otp', 'totp_secret': 'SECRET'});

      final result = await platform
          .enrollTotp(request(MfaEnrollTotpOptions(mfaToken: 'mfa-token')));

      expect(log.single.method, 'mfa#enrollTotp');
      expect(result.totpSecret, 'SECRET');
    });

    test('enrollPhone invokes the correct method', () async {
      mock({'authenticator_type': 'oob', 'oob_code': 'code'});

      await platform.enrollPhone(request(MfaEnrollPhoneOptions(
          mfaToken: 'mfa-token',
          phoneNumber: '+123')));

      expect(log.single.method, 'mfa#enrollPhone');
      expect((log.single.arguments as Map)['phoneNumber'], '+123');
    });

    test('challenge invokes the correct method and parses result', () async {
      mock({'challenge_type': 'oob', 'oob_code': 'code'});

      final result = await platform.challenge(request(
          MfaChallengeOptions(mfaToken: 'mfa-token', authenticatorId: 'sms|1')));

      expect(log.single.method, 'mfa#challenge');
      expect(result.oobCode, 'code');
    });

    test('verify invokes the correct method and parses credentials', () async {
      mock({
        'accessToken': 'access-token',
        'idToken': 'id-token',
        'refreshToken': 'refresh-token',
        'expiresAt': '2050-01-01T00:00:00.000Z',
        'scopes': ['openid'],
        'userProfile': {'sub': 'user-id'},
        'tokenType': 'Bearer',
      });

      final credentials = await platform.verify(request(MfaVerifyOptions(
          mfaToken: 'mfa-token',
          grantType: MfaVerifyGrantType.otp,
          otp: '123456')));

      expect(log.single.method, 'mfa#verify');
      expect((log.single.arguments as Map)['grantType'], 'otp');
      expect(credentials.accessToken, 'access-token');
      expect(credentials.user.sub, 'user-id');
    });

    test('throws MfaException on PlatformException', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (final call) async {
        throw PlatformException(
            code: 'expired_token',
            message: 'mfa_token is expired',
            details: <String, dynamic>{'_statusCode': 401});
      });

      expect(
        () => platform.challenge(request(MfaChallengeOptions(
            mfaToken: 'mfa-token', authenticatorId: 'sms|1'))),
        throwsA(isA<MfaException>()
            .having((final e) => e.code, 'code', 'expired_token')
            .having((final e) => e.isMfaTokenExpired, 'isMfaTokenExpired',
                true)),
      );
    });
  });
}
