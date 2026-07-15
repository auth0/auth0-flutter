import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'mfa_api_test.mocks.dart';

class TestPlatform extends Mock
    with
        // ignore: prefer_mixin
        MockPlatformInterfaceMixin
    implements
        Auth0FlutterMfaPlatform {
  static const MfaAuthenticator authenticator = MfaAuthenticator(
    id: 'sms|dev_1',
    type: 'phone',
    authenticatorType: 'oob',
    active: true,
    oobChannel: 'sms',
    name: '****4761',
  );

  static const MfaChallenge challengeResult = MfaChallenge(
    challengeType: 'oob',
    oobCode: 'oob-code',
    bindingMethod: 'prompt',
  );

  static const MfaEnrollmentChallenge enrollmentChallenge =
      MfaEnrollmentChallenge(
    authenticatorType: 'otp',
    totpSecret: 'SECRET',
    barcodeUri: 'otpauth://totp/...',
  );

  static Credentials credentials = Credentials.fromMap({
    'accessToken': 'accessToken',
    'idToken': 'idToken',
    'refreshToken': 'refreshToken',
    'expiresAt': DateTime.now().toIso8601String(),
    'scopes': ['openid'],
    'userProfile': {'sub': '123'},
    'tokenType': 'Bearer'
  });
}

@GenerateMocks([TestPlatform])
void main() {
  final mockedPlatform = MockTestPlatform();

  setUp(() {
    Auth0FlutterMfaPlatform.instance = mockedPlatform;
  });

  MfaApi mfa() =>
      Auth0('test-domain', 'test-clientId').mfa(mfaToken: 'mfa-token');

  group('getAuthenticators', () {
    test('forwards mfaToken and factors to the platform', () async {
      when(mockedPlatform.getAuthenticators(any))
          .thenAnswer((final _) async => [TestPlatform.authenticator]);

      final result = await mfa().getAuthenticators(factorsAllowed: ['phone']);

      final captured = verify(mockedPlatform.getAuthenticators(captureAny))
          .captured
          .single as ApiRequest<MfaGetAuthenticatorsOptions>;
      expect(captured.account.domain, 'test-domain');
      expect(captured.options.mfaToken, 'mfa-token');
      expect(captured.options.factorsAllowed, ['phone']);
      expect(result.single.id, 'sms|dev_1');
    });

    test('throws ArgumentError when factorsAllowed is empty', () {
      expect(
        () => mfa().getAuthenticators(factorsAllowed: []),
        throwsArgumentError,
      );
      verifyNever(mockedPlatform.getAuthenticators(any));
    });
  });

  group('enroll', () {
    test('enrollTotp delegates to the platform', () async {
      when(mockedPlatform.enrollTotp(any))
          .thenAnswer((final _) async => TestPlatform.enrollmentChallenge);

      final result = await mfa().enrollTotp();

      final captured = verify(mockedPlatform.enrollTotp(captureAny))
          .captured
          .single as ApiRequest<MfaEnrollTotpOptions>;
      expect(captured.options.mfaToken, 'mfa-token');
      expect(result.totpSecret, 'SECRET');
    });

    test('enrollPhone forwards phoneNumber', () async {
      when(mockedPlatform.enrollPhone(any))
          .thenAnswer((final _) async => TestPlatform.enrollmentChallenge);

      await mfa().enrollPhone(phoneNumber: '+1234567890');

      final captured = verify(mockedPlatform.enrollPhone(captureAny))
          .captured
          .single as ApiRequest<MfaEnrollPhoneOptions>;
      expect(captured.options.phoneNumber, '+1234567890');
    });

    test('enrollEmail forwards the email', () async {
      when(mockedPlatform.enrollEmail(any))
          .thenAnswer((final _) async => TestPlatform.enrollmentChallenge);

      await mfa().enrollEmail(email: 'user@example.com');

      final captured = verify(mockedPlatform.enrollEmail(captureAny))
          .captured
          .single as ApiRequest<MfaEnrollEmailOptions>;
      expect(captured.options.email, 'user@example.com');
    });

    test('enrollPush delegates to the platform', () async {
      when(mockedPlatform.enrollPush(any))
          .thenAnswer((final _) async => TestPlatform.enrollmentChallenge);

      await mfa().enrollPush();

      verify(mockedPlatform.enrollPush(any)).called(1);
    });
  });

  group('challenge', () {
    test('forwards authenticatorId', () async {
      when(mockedPlatform.challenge(any))
          .thenAnswer((final _) async => TestPlatform.challengeResult);

      final result = await mfa().challenge(authenticatorId: 'sms|dev_1');

      final captured = verify(mockedPlatform.challenge(captureAny))
          .captured
          .single as ApiRequest<MfaChallengeOptions>;
      expect(captured.options.authenticatorId, 'sms|dev_1');
      expect(result.oobCode, 'oob-code');
    });
  });

  group('verify', () {
    test('verifyOtp uses the otp grant type', () async {
      when(mockedPlatform.verify(any))
          .thenAnswer((final _) async => TestPlatform.credentials);

      final result = await mfa().verifyOtp(otp: '123456');

      final captured = verify(mockedPlatform.verify(captureAny))
          .captured
          .single as ApiRequest<MfaVerifyOptions>;
      expect(captured.options.grantType, MfaVerifyGrantType.otp);
      expect(captured.options.otp, '123456');
      expect(captured.options.scopes, {'openid', 'profile', 'email'});
      expect(captured.options.audience, isNull);
      expect(result.accessToken, 'accessToken');
    });

    test('verifyOtp forwards scopes and audience', () async {
      when(mockedPlatform.verify(any))
          .thenAnswer((final _) async => TestPlatform.credentials);

      await mfa().verifyOtp(
        otp: '123456',
        scopes: {'openid', 'profile'},
        audience: 'https://my-api.example.com',
      );

      final captured = verify(mockedPlatform.verify(captureAny))
          .captured
          .single as ApiRequest<MfaVerifyOptions>;
      expect(captured.options.scopes, {'openid', 'profile'});
      expect(captured.options.audience, 'https://my-api.example.com');
    });

    test('verifyOob uses the oob grant type with binding code', () async {
      when(mockedPlatform.verify(any))
          .thenAnswer((final _) async => TestPlatform.credentials);

      await mfa().verifyOob(oobCode: 'oob-code', bindingCode: '000111');

      final captured = verify(mockedPlatform.verify(captureAny))
          .captured
          .single as ApiRequest<MfaVerifyOptions>;
      expect(captured.options.grantType, MfaVerifyGrantType.oob);
      expect(captured.options.oobCode, 'oob-code');
      expect(captured.options.bindingCode, '000111');
    });

    test('verifyRecoveryCode uses the recovery_code grant type', () async {
      when(mockedPlatform.verify(any))
          .thenAnswer((final _) async => TestPlatform.credentials);

      await mfa().verifyRecoveryCode(recoveryCode: 'ABCD');

      final captured = verify(mockedPlatform.verify(captureAny))
          .captured
          .single as ApiRequest<MfaVerifyOptions>;
      expect(captured.options.grantType, MfaVerifyGrantType.recoveryCode);
      expect(captured.options.recoveryCode, 'ABCD');
    });
  });
}
