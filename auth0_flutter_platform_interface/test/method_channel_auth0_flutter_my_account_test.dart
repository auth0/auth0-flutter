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
      ).toMap();
      expect(map['id'], 'method-id');
      expect(map['authSession'], 'session');
      expect(map.containsKey('otp'), isFalse);
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
              accessToken: 'token', id: 'method-id', authSession: 'session'),
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
