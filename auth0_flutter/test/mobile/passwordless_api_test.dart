import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'passwordless_api_test.mocks.dart';

class TestPlatform extends Mock
    with
        // ignore: prefer_mixin
        MockPlatformInterfaceMixin
    implements
        Auth0FlutterAuthPlatform {
  static const PasswordlessChallenge challengeResult =
      PasswordlessChallenge(authSession: 'test-auth-session');

  static Credentials loginResult = Credentials.fromMap({
    'accessToken': 'accessToken',
    'idToken': 'idToken',
    'refreshToken': 'refreshToken',
    'expiresAt': DateTime.now().toIso8601String(),
    'scopes': ['a', 'b'],
    'userProfile': {'sub': '123', 'name': 'John Doe'},
    'tokenType': 'Bearer'
  });
}

@GenerateMocks([TestPlatform])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final mockedPlatform = MockTestPlatform();

  setUp(() {
    Auth0FlutterAuthPlatform.instance = mockedPlatform;
    reset(mockedPlatform);
  });

  group('challengeWithEmail', () {
    test('passes through properties to the platform', () async {
      when(mockedPlatform.passwordlessChallengeWithEmail(any))
          .thenAnswer((final _) async => TestPlatform.challengeResult);

      final result = await Auth0('test-domain', 'test-clientId')
          .passwordless
          .challengeWithEmail(
            email: 'test@example.com',
            connection: 'test-connection',
            allowSignup: true,
          );

      final verificationResult =
          verify(mockedPlatform.passwordlessChallengeWithEmail(captureAny))
                  .captured
                  .single
              as ApiRequest<AuthPasswordlessChallengeEmailOptions>;
      expect(verificationResult.account.domain, 'test-domain');
      expect(verificationResult.account.clientId, 'test-clientId');
      expect(verificationResult.options.email, 'test@example.com');
      expect(verificationResult.options.connection, 'test-connection');
      expect(verificationResult.options.allowSignup, true);
      expect(result, TestPlatform.challengeResult);
    });

    test('defaults allowSignup to false when omitted', () async {
      when(mockedPlatform.passwordlessChallengeWithEmail(any))
          .thenAnswer((final _) async => TestPlatform.challengeResult);

      await Auth0('test-domain', 'test-clientId')
          .passwordless
          .challengeWithEmail(
            email: 'test@example.com',
            connection: 'test-connection',
          );

      final verificationResult =
          verify(mockedPlatform.passwordlessChallengeWithEmail(captureAny))
                  .captured
                  .single
              as ApiRequest<AuthPasswordlessChallengeEmailOptions>;
      expect(verificationResult.options.allowSignup, false);
    });
  });

  group('challengeWithPhoneNumber', () {
    test('passes through properties to the platform', () async {
      when(mockedPlatform.passwordlessChallengeWithPhoneNumber(any))
          .thenAnswer((final _) async => TestPlatform.challengeResult);

      final result = await Auth0('test-domain', 'test-clientId')
          .passwordless
          .challengeWithPhoneNumber(
            phoneNumber: '+15551234567',
            connection: 'test-connection',
            deliveryMethod: DeliveryMethod.voice,
            allowSignup: true,
          );

      final verificationResult = verify(mockedPlatform
                  .passwordlessChallengeWithPhoneNumber(captureAny))
              .captured
              .single as ApiRequest<AuthPasswordlessChallengePhoneOptions>;
      expect(verificationResult.options.phoneNumber, '+15551234567');
      expect(verificationResult.options.connection, 'test-connection');
      expect(verificationResult.options.deliveryMethod, DeliveryMethod.voice);
      expect(verificationResult.options.allowSignup, true);
      expect(result, TestPlatform.challengeResult);
    });

    test('defaults deliveryMethod to text and allowSignup to false', () async {
      when(mockedPlatform.passwordlessChallengeWithPhoneNumber(any))
          .thenAnswer((final _) async => TestPlatform.challengeResult);

      await Auth0('test-domain', 'test-clientId')
          .passwordless
          .challengeWithPhoneNumber(
            phoneNumber: '+15551234567',
            connection: 'test-connection',
          );

      final verificationResult = verify(mockedPlatform
                  .passwordlessChallengeWithPhoneNumber(captureAny))
              .captured
              .single as ApiRequest<AuthPasswordlessChallengePhoneOptions>;
      expect(verificationResult.options.deliveryMethod, DeliveryMethod.text);
      expect(verificationResult.options.allowSignup, false);
    });
  });

  group('loginWithOtp', () {
    test('passes through properties to the platform', () async {
      when(mockedPlatform.passwordlessLoginWithOtp(any))
          .thenAnswer((final _) async => TestPlatform.loginResult);

      final result = await Auth0('test-domain', 'test-clientId')
          .passwordless
          .loginWithOtp(
            authSession: 'test-auth-session',
            otp: '123456',
            scopes: {'openid', 'profile'},
            audience: 'test-audience',
          );

      final verificationResult =
          verify(mockedPlatform.passwordlessLoginWithOtp(captureAny))
              .captured
              .single as ApiRequest<AuthPasswordlessLoginWithOtpOptions>;
      expect(verificationResult.options.authSession, 'test-auth-session');
      expect(verificationResult.options.otp, '123456');
      expect(verificationResult.options.scopes, {'openid', 'profile'});
      expect(verificationResult.options.audience, 'test-audience');
      expect(result, TestPlatform.loginResult);
    });

    test('defaults scopes to empty and audience to null when omitted',
        () async {
      when(mockedPlatform.passwordlessLoginWithOtp(any))
          .thenAnswer((final _) async => TestPlatform.loginResult);

      await Auth0('test-domain', 'test-clientId').passwordless.loginWithOtp(
            authSession: 'test-auth-session',
            otp: '123456',
          );

      final verificationResult =
          verify(mockedPlatform.passwordlessLoginWithOtp(captureAny))
              .captured
              .single as ApiRequest<AuthPasswordlessLoginWithOtpOptions>;
      expect(verificationResult.options.scopes, isEmpty);
      expect(verificationResult.options.audience, null);
    });
  });

  group('useDPoP', () {
    test('threads useDPoP from the Auth0 constructor into the request',
        () async {
      when(mockedPlatform.passwordlessChallengeWithEmail(any))
          .thenAnswer((final _) async => TestPlatform.challengeResult);

      await Auth0('test-domain', 'test-clientId', useDPoP: true)
          .passwordless
          .challengeWithEmail(
            email: 'test@example.com',
            connection: 'test-connection',
          );

      final verificationResult =
          verify(mockedPlatform.passwordlessChallengeWithEmail(captureAny))
                  .captured
                  .single
              as ApiRequest<AuthPasswordlessChallengeEmailOptions>;
      expect(verificationResult.useDPoP, true);
    });
  });
}
