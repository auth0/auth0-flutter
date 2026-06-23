import 'package:auth0_flutter/auth0_flutter_web.dart';
import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecordingWebPlatform extends Auth0FlutterWebPlatform {
  _RecordingWebPlatform() : super();

  // Calls recorded as (method, positional-args).
  final List<List<Object?>> calls = [];

  List<MfaAuthenticator> authenticatorsResult = const [];
  MfaEnrollmentChallenge enrollmentResult = const MfaEnrollmentChallenge();
  MfaChallenge challengeResult = const MfaChallenge(challengeType: 'oob');
  Credentials verifyResult = Credentials(
    idToken: 'id',
    accessToken: 'access',
    expiresAt: DateTime.utc(2030),
    user: const UserProfile(sub: 'auth0|1'),
    tokenType: 'Bearer',
  );

  @override
  Future<List<MfaAuthenticator>> mfaGetAuthenticators(final String mfaToken) {
    calls.add(['getAuthenticators', mfaToken]);
    return Future.value(authenticatorsResult);
  }

  @override
  Future<MfaEnrollmentChallenge> mfaEnrollTotp(final String mfaToken) {
    calls.add(['enrollTotp', mfaToken]);
    return Future.value(enrollmentResult);
  }

  @override
  Future<MfaEnrollmentChallenge> mfaEnrollPhone(
    final String mfaToken,
    final String phoneNumber,
    final PhoneType type,
  ) {
    calls.add(['enrollPhone', mfaToken, phoneNumber, type]);
    return Future.value(enrollmentResult);
  }

  @override
  Future<MfaEnrollmentChallenge> mfaEnrollEmail(
    final String mfaToken,
    final String email,
  ) {
    calls.add(['enrollEmail', mfaToken, email]);
    return Future.value(enrollmentResult);
  }

  @override
  Future<MfaEnrollmentChallenge> mfaEnrollPush(final String mfaToken) {
    calls.add(['enrollPush', mfaToken]);
    return Future.value(enrollmentResult);
  }

  @override
  Future<MfaChallenge> mfaChallenge(
    final String mfaToken,
    final String authenticatorId,
  ) {
    calls.add(['challenge', mfaToken, authenticatorId]);
    return Future.value(challengeResult);
  }

  @override
  Future<Credentials> mfaVerify(
    final String mfaToken,
    final MfaVerifyOptions options,
  ) {
    calls.add(['verify', mfaToken, options]);
    return Future.value(verifyResult);
  }
}

void main() {
  const mfaToken = 'mfa-token-123';
  final auth0 = Auth0Web('test-domain', 'test-client-id');
  late _RecordingWebPlatform platform;

  setUp(() {
    platform = _RecordingWebPlatform();
    Auth0FlutterWebPlatform.instance = platform;
  });

  test('Auth0Web.mfa returns an MfaWeb instance', () {
    expect(auth0.mfa(mfaToken: mfaToken), isA<MfaWeb>());
  });

  group('getAuthenticators', () {
    test('forwards the mfaToken and returns the authenticators', () async {
      platform.authenticatorsResult = const [
        MfaAuthenticator(
          id: 'sms|dev_1',
          authenticatorType: 'oob',
          oobChannel: 'sms',
          active: true,
          name: '+1******90',
        ),
      ];

      final result = await auth0.mfa(mfaToken: mfaToken).getAuthenticators();

      expect(platform.calls.single, ['getAuthenticators', mfaToken]);
      expect(result, hasLength(1));
      expect(result.first.id, 'sms|dev_1');
      expect(result.first.oobChannel, 'sms');
    });
  });

  group('enroll', () {
    test('enrollTotp forwards the mfaToken', () async {
      await auth0.mfa(mfaToken: mfaToken).enrollTotp();
      expect(platform.calls.single, ['enrollTotp', mfaToken]);
    });

    test('enrollPhone defaults to SMS and forwards the phone number', () async {
      await auth0.mfa(mfaToken: mfaToken).enrollPhone(phoneNumber: '+15551234');
      expect(platform.calls.single,
          ['enrollPhone', mfaToken, '+15551234', PhoneType.sms]);
    });

    test('enrollPhone passes the voice type when requested', () async {
      await auth0
          .mfa(mfaToken: mfaToken)
          .enrollPhone(phoneNumber: '+15551234', type: PhoneType.voice);
      expect(platform.calls.single,
          ['enrollPhone', mfaToken, '+15551234', PhoneType.voice]);
    });

    test('enrollEmail forwards the email', () async {
      await auth0
          .mfa(mfaToken: mfaToken)
          .enrollEmail(email: 'user@example.com');
      expect(platform.calls.single,
          ['enrollEmail', mfaToken, 'user@example.com']);
    });

    test('enrollPush forwards the mfaToken', () async {
      await auth0.mfa(mfaToken: mfaToken).enrollPush();
      expect(platform.calls.single, ['enrollPush', mfaToken]);
    });
  });

  group('challenge', () {
    test('forwards the mfaToken and authenticatorId', () async {
      await auth0
          .mfa(mfaToken: mfaToken)
          .challenge(authenticatorId: 'sms|dev_1');
      expect(platform.calls.single, ['challenge', mfaToken, 'sms|dev_1']);
    });
  });

  group('verify', () {
    test('verifyOtp builds an otp grant', () async {
      await auth0.mfa(mfaToken: mfaToken).verifyOtp(otp: '123456');

      final call = platform.calls.single;
      expect(call[0], 'verify');
      expect(call[1], mfaToken);
      final options = call[2] as MfaVerifyOptions;
      expect(options.grantType, MfaVerifyGrantType.otp);
      expect(options.otp, '123456');
    });

    test('verifyOob builds an oob grant with the binding code', () async {
      await auth0
          .mfa(mfaToken: mfaToken)
          .verifyOob(oobCode: 'oob-code', bindingCode: '000111');

      final options = platform.calls.single[2] as MfaVerifyOptions;
      expect(options.grantType, MfaVerifyGrantType.oob);
      expect(options.oobCode, 'oob-code');
      expect(options.bindingCode, '000111');
    });

    test('verifyRecoveryCode builds a recovery_code grant', () async {
      await auth0
          .mfa(mfaToken: mfaToken)
          .verifyRecoveryCode(recoveryCode: 'ABCD1234');

      final options = platform.calls.single[2] as MfaVerifyOptions;
      expect(options.grantType, MfaVerifyGrantType.recoveryCode);
      expect(options.recoveryCode, 'ABCD1234');
    });

    test('verify returns the credentials from the platform', () async {
      final credentials =
          await auth0.mfa(mfaToken: mfaToken).verifyOtp(otp: '123456');
      expect(credentials.accessToken, 'access');
      expect(credentials.idToken, 'id');
    });
  });
}
