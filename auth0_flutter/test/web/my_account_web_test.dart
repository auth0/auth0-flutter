import 'package:auth0_flutter/auth0_flutter_web.dart';
import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecordingWebPlatform extends Auth0FlutterWebPlatform {
  _RecordingWebPlatform() : super();

  // Calls recorded as (method, positional-args).
  final List<List<Object?>> calls = [];

  List<AuthenticationMethod> methodsResult = const [];
  AuthenticationMethod methodResult =
      const AuthenticationMethod(id: 'totp|dev_1', type: 'totp');
  List<Factor> factorsResult = const [];
  EnrollmentChallenge enrollmentResult =
      const EnrollmentChallenge(id: 'totp|dev_1', authSession: 'session');

  @override
  Future<List<AuthenticationMethod>> getAuthenticationMethods(
      String accessToken, AuthenticationMethodType? type) {
    calls.add(['getAuthenticationMethods', accessToken, type]);
    return Future.value(methodsResult);
  }

  @override
  Future<AuthenticationMethod> getAuthenticationMethod(
      String accessToken, String id) {
    calls.add(['getAuthenticationMethod', accessToken, id]);
    return Future.value(methodResult);
  }

  @override
  Future<void> deleteAuthenticationMethod(String accessToken, String id) {
    calls.add(['deleteAuthenticationMethod', accessToken, id]);
    return Future.value();
  }

  @override
  Future<AuthenticationMethod> updateAuthenticationMethod(String accessToken,
      String id, String? name, PhoneType? preferredAuthenticationMethod) {
    calls.add([
      'updateAuthenticationMethod',
      accessToken,
      id,
      name,
      preferredAuthenticationMethod
    ]);
    return Future.value(methodResult);
  }

  @override
  Future<List<Factor>> getFactors(String accessToken) {
    calls.add(['getFactors', accessToken]);
    return Future.value(factorsResult);
  }

  @override
  Future<EnrollmentChallenge> enrollPhone(
      String accessToken, String phoneNumber, PhoneType type) {
    calls.add(['enrollPhone', accessToken, phoneNumber, type]);
    return Future.value(enrollmentResult);
  }

  @override
  Future<EnrollmentChallenge> enrollEmail(String accessToken, String email) {
    calls.add(['enrollEmail', accessToken, email]);
    return Future.value(enrollmentResult);
  }

  @override
  Future<EnrollmentChallenge> enrollTotp(String accessToken) {
    calls.add(['enrollTotp', accessToken]);
    return Future.value(enrollmentResult);
  }

  @override
  Future<EnrollmentChallenge> enrollPush(String accessToken) {
    calls.add(['enrollPush', accessToken]);
    return Future.value(enrollmentResult);
  }

  @override
  Future<EnrollmentChallenge> enrollRecoveryCode(String accessToken) {
    calls.add(['enrollRecoveryCode', accessToken]);
    return Future.value(enrollmentResult);
  }

  @override
  Future<AuthenticationMethod> verifyOtp(String accessToken, String id,
      String authSession, String otp, String factorType) {
    calls.add(['verifyOtp', accessToken, id, authSession, otp, factorType]);
    return Future.value(methodResult);
  }

  @override
  Future<AuthenticationMethod> confirmEnrollment(
      String accessToken, String id, String authSession, String factorType) {
    calls.add(['confirmEnrollment', accessToken, id, authSession, factorType]);
    return Future.value(methodResult);
  }
}

void main() {
  const accessToken = 'my-account-access-token';
  final auth0 = Auth0Web('test-domain', 'test-client-id');
  late _RecordingWebPlatform platform;
  late MyAccountWeb myAccount;

  setUp(() {
    platform = _RecordingWebPlatform();
    Auth0FlutterWebPlatform.instance = platform;
    myAccount = auth0.myAccount(accessToken: accessToken);
  });

  test('Auth0Web.myAccount returns a MyAccountWeb instance', () {
    expect(auth0.myAccount(accessToken: accessToken), isA<MyAccountWeb>());
  });

  group('authentication methods', () {
    test('getAuthenticationMethods forwards the token and no filter', () async {
      platform.methodsResult = const [
        AuthenticationMethod(id: 'phone|dev_1', type: 'phone'),
      ];

      final result = await myAccount.getAuthenticationMethods();

      expect(platform.calls.single,
          ['getAuthenticationMethods', accessToken, null]);
      expect(result.single.id, 'phone|dev_1');
    });

    test('getAuthenticationMethods forwards the type filter', () async {
      await myAccount.getAuthenticationMethods(
          type: AuthenticationMethodType.phone);

      expect(platform.calls.single, [
        'getAuthenticationMethods',
        accessToken,
        AuthenticationMethodType.phone
      ]);
    });

    test('getAuthenticationMethod forwards the id', () async {
      final result = await myAccount.getAuthenticationMethod(id: 'totp|dev_1');

      expect(platform.calls.single,
          ['getAuthenticationMethod', accessToken, 'totp|dev_1']);
      expect(result.id, 'totp|dev_1');
    });

    test('deleteAuthenticationMethod forwards the id', () async {
      await myAccount.deleteAuthenticationMethod(id: 'totp|dev_1');

      expect(platform.calls.single,
          ['deleteAuthenticationMethod', accessToken, 'totp|dev_1']);
    });

    test('updateAuthenticationMethod forwards the name and phone type',
        () async {
      await myAccount.updateAuthenticationMethod(
          id: 'phone|dev_1',
          name: 'My phone',
          preferredAuthenticationMethod: PhoneType.voice);

      expect(platform.calls.single, [
        'updateAuthenticationMethod',
        accessToken,
        'phone|dev_1',
        'My phone',
        PhoneType.voice
      ]);
    });

    test('updateAuthenticationMethod leaves omitted fields null', () async {
      await myAccount.updateAuthenticationMethod(id: 'phone|dev_1');

      expect(platform.calls.single, [
        'updateAuthenticationMethod',
        accessToken,
        'phone|dev_1',
        null,
        null
      ]);
    });
  });

  test('getFactors forwards the token', () async {
    platform.factorsResult = const [Factor(type: 'totp')];

    final result = await myAccount.getFactors();

    expect(platform.calls.single, ['getFactors', accessToken]);
    expect(result.single.type, 'totp');
  });

  group('enroll', () {
    test('enrollPhone forwards the phone number and type', () async {
      await myAccount.enrollPhone(
          phoneNumber: '+15555550100', type: PhoneType.sms);

      expect(platform.calls.single,
          ['enrollPhone', accessToken, '+15555550100', PhoneType.sms]);
    });

    test('enrollEmail forwards the email', () async {
      await myAccount.enrollEmail(email: 'user@example.com');

      expect(platform.calls.single,
          ['enrollEmail', accessToken, 'user@example.com']);
    });

    test('enrollTotp forwards the token and returns the challenge', () async {
      final result = await myAccount.enrollTotp();

      expect(platform.calls.single, ['enrollTotp', accessToken]);
      expect(result.authSession, 'session');
    });

    test('enrollPush forwards the token', () async {
      await myAccount.enrollPush();

      expect(platform.calls.single, ['enrollPush', accessToken]);
    });

    test('enrollRecoveryCode forwards the token', () async {
      await myAccount.enrollRecoveryCode();

      expect(platform.calls.single, ['enrollRecoveryCode', accessToken]);
    });
  });

  group('confirm', () {
    test('verifyOtp forwards the challenge, otp and factor type', () async {
      await myAccount.verifyOtp(
          id: 'totp|dev_1',
          authSession: 'session',
          otp: '123456',
          factorType: 'totp');

      expect(platform.calls.single, [
        'verifyOtp',
        accessToken,
        'totp|dev_1',
        'session',
        '123456',
        'totp'
      ]);
    });

    test('confirmEnrollment forwards the challenge and factor type', () async {
      await myAccount.confirmEnrollment(
          id: 'push-notification|dev_1',
          authSession: 'session',
          factorType: 'push-notification');

      expect(platform.calls.single, [
        'confirmEnrollment',
        accessToken,
        'push-notification|dev_1',
        'session',
        'push-notification'
      ]);
    });
  });
}
