// ignore_for_file: lines_longer_than_80_chars

import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'method_channel_auth0_flutter_auth_test.mocks.dart';

class MethodCallHandler {
  static const Map<dynamic, dynamic> loginResultRequired = {
    'accessToken': 'accessToken',
    'idToken': 'idToken',
    'expiresAt': '2022-01-01',
    'scopes': ['a', 'b'],
    'userProfile': {'sub': '123', 'name': 'John Doe'},
    'tokenType': 'Bearer'
  };

  static const Map<dynamic, dynamic> loginResult = {
    ...loginResultRequired,
    'refreshToken': 'refreshToken'
  };

  static const Map<dynamic, dynamic> multifactorChallengeResultRequired = {
    'challengeType': 'otp'
  };

  static const Map<dynamic, dynamic> multifactorChallengeResult = {
    ...multifactorChallengeResultRequired,
    'oobCode': 'oobCode',
    'bindingMethod': 'bindingMethod'
  };

  static const Map<dynamic, dynamic> signupResultRequired = {
    'email': 'test-email',
    'emailVerified': true
  };

  static const Map<dynamic, dynamic> signupResult = {
    ...signupResultRequired,
    'username': 'test-user'
  };

  static const Map<dynamic, dynamic> renewResult = {
    'accessToken': 'accessToken',
    'idToken': 'idToken',
    'refreshToken': 'refreshToken',
    'expiresAt': '2022-01-01',
    'scopes': ['a', 'b'],
    'userProfile': {'sub': '123', 'name': 'John Doe'},
    'tokenType': 'Bearer'
  };

  Future<dynamic>? methodCallHandler(final MethodCall? methodCall) async {}
}

@GenerateMocks([MethodCallHandler])
void main() {
  const MethodChannel channel = MethodChannel('auth0.com/auth0_flutter/auth');

  TestWidgetsFlutterBinding.ensureInitialized();

  final mocked = MockMethodCallHandler();

  setUp(() {
    channel.setMockMethodCallHandler(mocked.methodCallHandler);
    reset(mocked);
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  group('signup', () {
    test('calls the correct MethodChannel method', () async {
      when(mocked.methodCallHandler(any))
          .thenAnswer((final _) async => MethodCallHandler.signupResult);

      await MethodChannelAuth0FlutterAuth().signup(
          ApiRequest<AuthSignupOptions>(
              account: const Account('test-domain', 'test-clientId'),
              userAgent: UserAgent(name: 'test-name', version: 'test-version'),
              options: AuthSignupOptions(
                  email: 'test-email',
                  password: 'test-pass',
                  connection: 'test-connection',
                  username: 'test-user')));

      expect(
          verify(mocked.methodCallHandler(captureAny)).captured.single.method,
          'auth#signUp');
    });

    test('correctly maps all properties', () async {
      when(mocked.methodCallHandler(any))
          .thenAnswer((final _) async => MethodCallHandler.signupResult);

      await MethodChannelAuth0FlutterAuth().signup(
          ApiRequest<AuthSignupOptions>(
              account: const Account('test-domain', 'test-clientId'),
              userAgent: UserAgent(name: 'test-name', version: 'test-version'),
              options: AuthSignupOptions(
                  email: 'test-email',
                  password: 'test-pass',
                  connection: 'test-connection',
                  username: 'test-user',
                  userMetadata: {'test': 'test-123'})));

      final verificationResult =
          verify(mocked.methodCallHandler(captureAny)).captured.single;
      expect(verificationResult.arguments['_account']['domain'], 'test-domain');
      expect(verificationResult.arguments['_account']['clientId'],
          'test-clientId');
      expect(verificationResult.arguments['_userAgent']['name'], 'test-name');
      expect(verificationResult.arguments['_userAgent']['version'],
          'test-version');
      expect(verificationResult.arguments['email'], 'test-email');
      expect(verificationResult.arguments['username'], 'test-user');
      expect(verificationResult.arguments['password'], 'test-pass');
      expect(verificationResult.arguments['connection'], 'test-connection');
      expect(verificationResult.arguments['userMetadata']['test'], 'test-123');
    });

    test(
        'correctly assigns default values to all non-required properties when missing',
        () async {
      when(mocked.methodCallHandler(any))
          .thenAnswer((final _) async => MethodCallHandler.signupResult);

      await MethodChannelAuth0FlutterAuth().signup(
          ApiRequest<AuthSignupOptions>(
              account: const Account('', ''),
              userAgent: UserAgent(name: '', version: ''),
              options:
                  AuthSignupOptions(email: '', password: '', connection: '')));

      final verificationResult =
          verify(mocked.methodCallHandler(captureAny)).captured.single;
      expect(verificationResult.arguments['username'], isNull);
      expect(verificationResult.arguments['userMetadata'], isEmpty);
    });

    test('correctly returns the response from the Method Channel', () async {
      when(mocked.methodCallHandler(any))
          .thenAnswer((final _) async => MethodCallHandler.signupResult);

      final result = await MethodChannelAuth0FlutterAuth().signup(
          ApiRequest<AuthSignupOptions>(
              account: const Account('test-domain', 'test-clientId'),
              userAgent: UserAgent(name: 'test-name', version: 'test-version'),
              options: AuthSignupOptions(
                  email: 'test-email',
                  password: 'test-pass',
                  connection: 'test-connection')));

      verify(mocked.methodCallHandler(captureAny));

      expect(result.email, 'test-email');
      expect(result.isEmailVerified, true);
      expect(result.username, 'test-user');
    });

    test(
        'correctly returns the response from the Method Channel when properties missing',
        () async {
      when(mocked.methodCallHandler(any)).thenAnswer(
          (final _) async => MethodCallHandler.signupResultRequired);

      final result = await MethodChannelAuth0FlutterAuth().signup(
          ApiRequest<AuthSignupOptions>(
              account: const Account('', ''),
              userAgent: UserAgent(name: '', version: ''),
              options:
                  AuthSignupOptions(email: '', password: '', connection: '')));

      verify(mocked.methodCallHandler(captureAny));
      expect(result.username, isNull);
    });

    test('correctly returns emailVerified when true', () async {
      when(mocked.methodCallHandler(any)).thenAnswer((final _) async =>
          {...MethodCallHandler.signupResult, 'emailVerified': true});

      final result = await MethodChannelAuth0FlutterAuth().signup(
          ApiRequest<AuthSignupOptions>(
              account: const Account('test-domain', 'test-clientId'),
              userAgent: UserAgent(name: 'test-name', version: 'test-version'),
              options:
                  AuthSignupOptions(email: '', password: '', connection: '')));

      verify(mocked.methodCallHandler(captureAny));
      expect(result.isEmailVerified, true);
    });

    test('correctly returns emailVerified when false', () async {
      when(mocked.methodCallHandler(any)).thenAnswer((final _) async =>
          {...MethodCallHandler.signupResult, 'emailVerified': false});

      final result = await MethodChannelAuth0FlutterAuth().signup(
          ApiRequest<AuthSignupOptions>(
              account: const Account('', ''),
              userAgent: UserAgent(name: 'test-name', version: 'test-version'),
              options:
                  AuthSignupOptions(email: '', password: '', connection: '')));

      verify(mocked.methodCallHandler(captureAny));
      expect(result.isEmailVerified, false);
    });

    test('throws an ApiException when method channel returns null', () async {
      when(mocked.methodCallHandler(any)).thenAnswer((final _) async => null);

      Future<DatabaseUser> actual() async {
        final result = await MethodChannelAuth0FlutterAuth().signup(ApiRequest<
                AuthSignupOptions>(
            account: const Account('', ''),
            userAgent: UserAgent(name: 'test-name', version: 'test-version'),
            options:
                AuthSignupOptions(email: '', password: '', connection: '')));

        return result;
      }

      expectLater(
          actual,
          throwsA(predicate((final e) =>
              e is ApiException && e.message == 'Channel returned null.')));
    });

    test(
        'throws an ApiException when method channel throws a PlatformException',
        () async {
      when(mocked.methodCallHandler(any))
          .thenThrow(PlatformException(code: '123'));

      Future<DatabaseUser> actual() async {
        final result = await MethodChannelAuth0FlutterAuth().signup(ApiRequest<
                AuthSignupOptions>(
            account: const Account('', ''),
            userAgent: UserAgent(name: 'test-name', version: 'test-version'),
            options:
                AuthSignupOptions(email: '', password: '', connection: '')));

        return result;
      }

      await expectLater(actual, throwsA(isA<ApiException>()));
    });
  });

  group('login', () {
    test('calls the correct MethodChannel method', () async {
      when(mocked.methodCallHandler(any))
          .thenAnswer((final _) async => MethodCallHandler.loginResult);

      await MethodChannelAuth0FlutterAuth().login(
        ApiRequest<AuthLoginOptions>(
            account: const Account('', ''),
            userAgent: UserAgent(name: 'test-name', version: 'test-version'),
            options: AuthLoginOptions(
                usernameOrEmail: 'test-email',
                password: 'test-pass',
                connectionOrRealm: 'test-connection',
                scopes: {'a', 'b'},
                parameters: {'test': 'test-123'})),
      );

      expect(
          verify(mocked.methodCallHandler(captureAny)).captured.single.method,
          'auth#login');
    });

    test('correctly maps all properties', () async {
      when(mocked.methodCallHandler(any))
          .thenAnswer((final _) async => MethodCallHandler.loginResult);

      await MethodChannelAuth0FlutterAuth().login(
        ApiRequest<AuthLoginOptions>(
            account: const Account('test-domain', 'test-clientId'),
            userAgent: UserAgent(name: 'test-name', version: 'test-version'),
            options: AuthLoginOptions(
                usernameOrEmail: 'test-email',
                password: 'test-pass',
                connectionOrRealm: 'test-connection',
                audience: 'test-audience',
                scopes: {'a', 'b'},
                parameters: {'test': 'test-123'})),
      );

      final verificationResult =
          verify(mocked.methodCallHandler(captureAny)).captured.single;
      expect(verificationResult.arguments['_account']['domain'], 'test-domain');
      expect(verificationResult.arguments['_account']['clientId'],
          'test-clientId');
      expect(verificationResult.arguments['_userAgent']['name'], 'test-name');
      expect(verificationResult.arguments['_userAgent']['version'],
          'test-version');
      expect(verificationResult.arguments['usernameOrEmail'], 'test-email');
      expect(verificationResult.arguments['password'], 'test-pass');
      expect(
          verificationResult.arguments['connectionOrRealm'], 'test-connection');
      expect(verificationResult.arguments['audience'], 'test-audience');
      expect(verificationResult.arguments['scopes'], ['a', 'b']);
      expect(verificationResult.arguments['parameters']['test'], 'test-123');
    });

    test(
        'correctly assigns default values to all non-required properties when missing',
        () async {
      when(mocked.methodCallHandler(any))
          .thenAnswer((final _) async => MethodCallHandler.loginResult);

      await MethodChannelAuth0FlutterAuth().login(ApiRequest<AuthLoginOptions>(
          account: const Account('', ''),
          userAgent: UserAgent(name: '', version: ''),
          options: AuthLoginOptions(
              usernameOrEmail: '', password: '', connectionOrRealm: '')));

      final verificationResult =
          verify(mocked.methodCallHandler(captureAny)).captured.single;
      expect(verificationResult.arguments['scopes'], isEmpty);
      expect(verificationResult.arguments['parameters'], isEmpty);
    });

    test('correctly returns the response from the Method Channel', () async {
      when(mocked.methodCallHandler(any))
          .thenAnswer((final _) async => MethodCallHandler.loginResult);

      final result = await MethodChannelAuth0FlutterAuth().login(
        ApiRequest<AuthLoginOptions>(
            account: const Account('', ''),
            userAgent: UserAgent(name: 'test-name', version: 'test-version'),
            options: AuthLoginOptions(
                usernameOrEmail: 'test-email',
                password: 'test-pass',
                connectionOrRealm: 'test-connection')),
      );

      verify(mocked.methodCallHandler(captureAny));

      expect(result.accessToken, MethodCallHandler.loginResult['accessToken']);
      expect(result.idToken, MethodCallHandler.loginResult['idToken']);
      expect(result.expiresAt,
          DateTime.parse(MethodCallHandler.loginResult['expiresAt'] as String));
      expect(result.scopes, MethodCallHandler.loginResult['scopes']);
      expect(
          result.refreshToken, MethodCallHandler.loginResult['refreshToken']);
      expect(result.user.name,
          MethodCallHandler.loginResult['userProfile']['name']);
    });

    test(
        'correctly returns the response from the Method Channel when properties missing',
        () async {
      when(mocked.methodCallHandler(any))
          .thenAnswer((final _) async => MethodCallHandler.loginResultRequired);

      final result = await MethodChannelAuth0FlutterAuth().login(
          ApiRequest<AuthLoginOptions>(
              account: const Account('', ''),
              userAgent: UserAgent(name: '', version: ''),
              options: AuthLoginOptions(
                  usernameOrEmail: '', password: '', connectionOrRealm: '')));

      verify(mocked.methodCallHandler(captureAny));

      expect(result.refreshToken, isNull);
    });

    test('throws an ApiException when method channel returns null', () async {
      when(mocked.methodCallHandler(any)).thenAnswer((final _) async => null);

      Future<Credentials> actual() async {
        final result = await MethodChannelAuth0FlutterAuth().login(
          ApiRequest<AuthLoginOptions>(
              account: const Account('', ''),
              userAgent: UserAgent(name: 'test-name', version: 'test-version'),
              options: AuthLoginOptions(
                  usernameOrEmail: 'test-email',
                  password: 'test-pass',
                  connectionOrRealm: 'test-connection',
                  scopes: {'a', 'b'},
                  parameters: {'test': 'test-123'})),
        );

        return result;
      }

      await expectLater(actual, throwsA(isA<ApiException>()));
    });

    test(
        'throws an ApiException when method channel throws a PlatformException',
        () async {
      when(mocked.methodCallHandler(any))
          .thenThrow(PlatformException(code: '123'));

      Future<Credentials> actual() async {
        final result = await MethodChannelAuth0FlutterAuth().login(
          ApiRequest<AuthLoginOptions>(
              account: const Account('', ''),
              userAgent: UserAgent(name: 'test-name', version: 'test-version'),
              options: AuthLoginOptions(
                  usernameOrEmail: 'test-email',
                  password: 'test-pass',
                  connectionOrRealm: 'test-connection',
                  scopes: {'a', 'b'},
                  parameters: {'test': 'test-123'})),
        );

        return result;
      }

      await expectLater(actual, throwsA(isA<ApiException>()));
    });
  });

  group('loginWithOtp', () {
    test('calls the correct MethodChannel method', () async {
      when(mocked.methodCallHandler(any))
          .thenAnswer((final _) async => MethodCallHandler.loginResult);

      await MethodChannelAuth0FlutterAuth().loginWithOtp(
        ApiRequest<AuthLoginWithOtpOptions>(
            account: const Account('', ''),
            userAgent: UserAgent(name: 'test-name', version: 'test-version'),
            options: AuthLoginWithOtpOptions(
                otp: 'test-otp', mfaToken: 'test-mfa-token')),
      );

      expect(
          verify(mocked.methodCallHandler(captureAny)).captured.single.method,
          'auth#loginOtp');
    });

    test('correctly maps all properties', () async {
      when(mocked.methodCallHandler(any))
          .thenAnswer((final _) async => MethodCallHandler.loginResult);

      await MethodChannelAuth0FlutterAuth().loginWithOtp(
        ApiRequest<AuthLoginWithOtpOptions>(
            account: const Account('test-domain', 'test-clientId'),
            userAgent: UserAgent(name: 'test-name', version: 'test-version'),
            options: AuthLoginWithOtpOptions(
                otp: 'test-otp', mfaToken: 'test-mfa-token')),
      );

      final verificationResult =
          verify(mocked.methodCallHandler(captureAny)).captured.single;
      expect(verificationResult.arguments['_account']['domain'], 'test-domain');
      expect(verificationResult.arguments['_account']['clientId'],
          'test-clientId');
      expect(verificationResult.arguments['_userAgent']['name'], 'test-name');
      expect(verificationResult.arguments['_userAgent']['version'],
          'test-version');
      expect(verificationResult.arguments['otp'], 'test-otp');
      expect(verificationResult.arguments['mfaToken'], 'test-mfa-token');
    });

    test('correctly returns the response from the Method Channel', () async {
      when(mocked.methodCallHandler(any))
          .thenAnswer((final _) async => MethodCallHandler.loginResult);

      final result = await MethodChannelAuth0FlutterAuth().loginWithOtp(
        ApiRequest<AuthLoginWithOtpOptions>(
            account: const Account('', ''),
            userAgent: UserAgent(name: 'test-name', version: 'test-version'),
            options: AuthLoginWithOtpOptions(
                mfaToken: 'test-mfa-token', otp: 'test-otp')),
      );

      verify(mocked.methodCallHandler(captureAny));

      expect(result.accessToken, MethodCallHandler.loginResult['accessToken']);
      expect(result.idToken, MethodCallHandler.loginResult['idToken']);
      expect(result.expiresAt,
          DateTime.parse(MethodCallHandler.loginResult['expiresAt'] as String));
      expect(result.scopes, MethodCallHandler.loginResult['scopes']);
      expect(
          result.refreshToken, MethodCallHandler.loginResult['refreshToken']);
      expect(result.user.name,
          MethodCallHandler.loginResult['userProfile']['name']);
    });

    test(
        'correctly returns the response from the Method Channel when properties missing',
        () async {
      when(mocked.methodCallHandler(any))
          .thenAnswer((final _) async => MethodCallHandler.loginResultRequired);

      final result = await MethodChannelAuth0FlutterAuth().loginWithOtp(
          ApiRequest<AuthLoginWithOtpOptions>(
              account: const Account('', ''),
              userAgent: UserAgent(name: '', version: ''),
              options: AuthLoginWithOtpOptions(otp: '', mfaToken: '')));

      verify(mocked.methodCallHandler(captureAny));

      expect(result.refreshToken, isNull);
    });

    test('throws an ApiException when method channel returns null', () async {
      when(mocked.methodCallHandler(any)).thenAnswer((final _) async => null);

      Future<Credentials> actual() async {
        final result = await MethodChannelAuth0FlutterAuth().loginWithOtp(
          ApiRequest<AuthLoginWithOtpOptions>(
              account: const Account('', ''),
              userAgent: UserAgent(name: 'test-name', version: 'test-version'),
              options: AuthLoginWithOtpOptions(otp: '', mfaToken: '')),
        );

        return result;
      }

      await expectLater(actual, throwsA(isA<ApiException>()));
    });

    test(
        'throws an ApiException when method channel throws a PlatformException',
        () async {
      when(mocked.methodCallHandler(any))
          .thenThrow(PlatformException(code: '123'));

      Future<Credentials> actual() async {
        final result = await MethodChannelAuth0FlutterAuth().loginWithOtp(
          ApiRequest<AuthLoginWithOtpOptions>(
              account: const Account('', ''),
              userAgent: UserAgent(name: 'test-name', version: 'test-version'),
              options: AuthLoginWithOtpOptions(otp: '', mfaToken: '')),
        );

        return result;
      }

      await expectLater(actual, throwsA(isA<ApiException>()));
    });
  });

  group('multifactorChallenge', () {
    test('calls the correct MethodChannel method', () async {
      when(mocked.methodCallHandler(any)).thenAnswer((final _) async =>
          MethodCallHandler.multifactorChallengeResultRequired);

      await MethodChannelAuth0FlutterAuth().multifactorChallenge(
          ApiRequest<AuthMultifactorChallengeOptions>(
              account: const Account('', ''),
              userAgent: UserAgent(name: '', version: ''),
              options: AuthMultifactorChallengeOptions(mfaToken: '')));

      expect(
          verify(mocked.methodCallHandler(captureAny)).captured.single.method,
          'auth#multifactorChallenge');
    });

    test('correctly maps all properties', () async {
      when(mocked.methodCallHandler(any)).thenAnswer(
          (final _) async => MethodCallHandler.multifactorChallengeResult);

      await MethodChannelAuth0FlutterAuth().multifactorChallenge(
          ApiRequest<AuthMultifactorChallengeOptions>(
              account: const Account('test-domain', 'test-clientId'),
              userAgent: UserAgent(name: 'test-name', version: 'test-version'),
              options: AuthMultifactorChallengeOptions(
                  mfaToken: 'test-mfa-token',
                  types: [ChallengeType.otp, ChallengeType.oob],
                  authenticatorId: 'test-authenticatorId')));

      final verificationResult =
          verify(mocked.methodCallHandler(captureAny)).captured.single;
      expect(verificationResult.arguments['_account']['domain'], 'test-domain');
      expect(verificationResult.arguments['_account']['clientId'],
          'test-clientId');
      expect(verificationResult.arguments['_userAgent']['name'], 'test-name');
      expect(verificationResult.arguments['_userAgent']['version'],
          'test-version');
      expect(verificationResult.arguments['mfaToken'], 'test-mfa-token');
      expect(verificationResult.arguments['types'],
          [ChallengeType.otp.value, ChallengeType.oob.value]);
      expect(verificationResult.arguments['authenticatorId'],
          'test-authenticatorId');
    });

    test(
        'correctly assigns default values to all non-required properties when missing',
        () async {
      when(mocked.methodCallHandler(any)).thenAnswer((final _) async =>
          MethodCallHandler.multifactorChallengeResultRequired);

      await MethodChannelAuth0FlutterAuth().multifactorChallenge(
          ApiRequest<AuthMultifactorChallengeOptions>(
              account: const Account('', ''),
              userAgent: UserAgent(name: '', version: ''),
              options:
                  AuthMultifactorChallengeOptions(mfaToken: 'test-mfa-token')));

      final verificationResult =
          verify(mocked.methodCallHandler(captureAny)).captured.single;
      expect(verificationResult.arguments['types'], isNull);
      expect(verificationResult.arguments['authenticatorId'], isNull);
    });

    test('correctly returns the response from the Method Channel', () async {
      when(mocked.methodCallHandler(any)).thenAnswer(
          (final _) async => MethodCallHandler.multifactorChallengeResult);

      final result = await MethodChannelAuth0FlutterAuth().multifactorChallenge(
          ApiRequest<AuthMultifactorChallengeOptions>(
              account: const Account('test-domain', 'test-clientId'),
              userAgent: UserAgent(name: 'test-name', version: 'test-version'),
              options: AuthMultifactorChallengeOptions(mfaToken: '')));

      verify(mocked.methodCallHandler(captureAny));

      expect(result.type, ChallengeType.otp);
      expect(result.oobCode, 'oobCode');
      expect(result.bindingMethod, 'bindingMethod');
    });

    test(
        'correctly returns the response from the Method Channel when properties missing',
        () async {
      when(mocked.methodCallHandler(any)).thenAnswer((final _) async =>
          MethodCallHandler.multifactorChallengeResultRequired);

      final result = await MethodChannelAuth0FlutterAuth().multifactorChallenge(
          ApiRequest<AuthMultifactorChallengeOptions>(
              account: const Account('', ''),
              userAgent: UserAgent(name: '', version: ''),
              options: AuthMultifactorChallengeOptions(mfaToken: '')));

      verify(mocked.methodCallHandler(captureAny));

      expect(result.type, ChallengeType.otp);
      expect(result.oobCode, isNull);
      expect(result.bindingMethod, isNull);
    });

    test('throws an ApiException when method channel returns null', () async {
      when(mocked.methodCallHandler(any)).thenAnswer((final _) async => null);

      Future<Challenge> actual() async {
        final result = await MethodChannelAuth0FlutterAuth()
            .multifactorChallenge(ApiRequest<AuthMultifactorChallengeOptions>(
                account: const Account('', ''),
                userAgent: UserAgent(name: '', version: ''),
                options: AuthMultifactorChallengeOptions(mfaToken: '')));

        return result;
      }

      expectLater(
          actual,
          throwsA(predicate((final e) =>
              e is ApiException && e.message == 'Channel returned null.')));
    });

    test(
        'throws an ApiException when method channel throws a PlatformException',
        () async {
      when(mocked.methodCallHandler(any))
          .thenThrow(PlatformException(code: '123'));

      Future<DatabaseUser> actual() async {
        final result = await MethodChannelAuth0FlutterAuth().signup(
            ApiRequest<AuthSignupOptions>(
                account: const Account('', ''),
                userAgent: UserAgent(name: '', version: ''),
                options: AuthSignupOptions(
                    email: '', password: '', connection: '', parameters: {})));

        return result;
      }

      await expectLater(actual, throwsA(isA<ApiException>()));
    });
  });

  group('resetPassword', () {
    test('calls the correct MethodChannel method', () async {
      when(mocked.methodCallHandler(any)).thenAnswer((final _) async => null);

      await MethodChannelAuth0FlutterAuth().resetPassword(ApiRequest(
          account: const Account('test-domain', 'test-clientId'),
          userAgent: UserAgent(name: 'test-name', version: 'test-version'),
          options: AuthResetPasswordOptions(
              email: 'test-email', connection: 'test-connection')));

      expect(
          verify(mocked.methodCallHandler(captureAny)).captured.single.method,
          'auth#resetPassword');
    });

    test('correctly maps all properties', () async {
      when(mocked.methodCallHandler(any)).thenAnswer((final _) async => null);

      await MethodChannelAuth0FlutterAuth().resetPassword(ApiRequest(
          account: const Account('test-domain', 'test-clientId'),
          userAgent: UserAgent(name: 'test-name', version: 'test-version'),
          options: AuthResetPasswordOptions(
              email: 'test-email',
              connection: 'test-connection',
              parameters: {'test': 'test-123'})));

      final verificationResult =
          verify(mocked.methodCallHandler(captureAny)).captured.single;
      expect(verificationResult.arguments['_account']['domain'], 'test-domain');
      expect(verificationResult.arguments['_account']['clientId'],
          'test-clientId');
      expect(verificationResult.arguments['_userAgent']['name'], 'test-name');
      expect(verificationResult.arguments['_userAgent']['version'],
          'test-version');
      expect(verificationResult.arguments['email'], 'test-email');
      expect(verificationResult.arguments['connection'], 'test-connection');
      expect(verificationResult.arguments['parameters']['test'], 'test-123');
    });

    test(
        'correctly assigns default values to all non-required properties when missing',
        () async {
      when(mocked.methodCallHandler(any)).thenAnswer((final _) async => null);

      await MethodChannelAuth0FlutterAuth().resetPassword(ApiRequest(
          account: const Account('', ''),
          userAgent: UserAgent(name: '', version: ''),
          options: AuthResetPasswordOptions(email: '', connection: '')));

      final verificationResult =
          verify(mocked.methodCallHandler(captureAny)).captured.single;
      expect(verificationResult.arguments['parameters'], isEmpty);
    });

    test(
        'throws an ApiException when method channel throws a PlatformException',
        () async {
      when(mocked.methodCallHandler(any))
          .thenThrow(PlatformException(code: '123'));

      Future<void> actual() async {
        await MethodChannelAuth0FlutterAuth().resetPassword(ApiRequest(
            account: const Account('test-domain', 'test-clientId'),
            userAgent: UserAgent(name: 'test-name', version: 'test-version'),
            options: AuthResetPasswordOptions(
                email: 'test-email',
                connection: 'test-connection',
                parameters: {'test': 'test-123'})));
      }

      await expectLater(actual, throwsA(isA<ApiException>()));
    });
  });

  group('renew', () {
    test('calls the correct MethodChannel method', () async {
      when(mocked.methodCallHandler(any))
          .thenAnswer((final _) async => MethodCallHandler.renewResult);

      await MethodChannelAuth0FlutterAuth().renew(ApiRequest<AuthRenewOptions>(
          account: const Account('test-domain', 'test-clientId'),
          userAgent: UserAgent(name: 'test-name', version: 'test-version'),
          options: AuthRenewOptions(refreshToken: 'test-refresh-token')));

      expect(
          verify(mocked.methodCallHandler(captureAny)).captured.single.method,
          'auth#renew');
    });

    test('correctly maps all properties', () async {
      when(mocked.methodCallHandler(any))
          .thenAnswer((final _) async => MethodCallHandler.renewResult);

      await MethodChannelAuth0FlutterAuth().renew(ApiRequest<AuthRenewOptions>(
          account: const Account('test-domain', 'test-clientId'),
          userAgent: UserAgent(name: 'test-name', version: 'test-version'),
          options: AuthRenewOptions(
              refreshToken: 'test-refresh-token',
              scopes: {'a', 'b'},
              parameters: {'test': 'test-123'})));

      final verificationResult =
          verify(mocked.methodCallHandler(captureAny)).captured.single;
      expect(verificationResult.arguments['_account']['domain'], 'test-domain');
      expect(verificationResult.arguments['_account']['clientId'],
          'test-clientId');
      expect(verificationResult.arguments['_userAgent']['name'], 'test-name');
      expect(verificationResult.arguments['_userAgent']['version'],
          'test-version');
      expect(
          verificationResult.arguments['refreshToken'], 'test-refresh-token');
      expect(verificationResult.arguments['scopes'], {'a', 'b'});
      expect(verificationResult.arguments['parameters']['test'], 'test-123');
    });

    test(
        'correctly assigns default values to all non-required properties when missing',
        () async {
      when(mocked.methodCallHandler(any))
          .thenAnswer((final _) async => MethodCallHandler.renewResult);

      await MethodChannelAuth0FlutterAuth().renew(ApiRequest<AuthRenewOptions>(
          account: const Account('', ''),
          userAgent: UserAgent(name: '', version: ''),
          options: AuthRenewOptions(refreshToken: '')));
      final verificationResult =
          verify(mocked.methodCallHandler(captureAny)).captured.single;
      expect(verificationResult.arguments['scopes'], isEmpty);
      expect(verificationResult.arguments['parameters'], isEmpty);
    });

    test('correctly returns the response from the Method Channel', () async {
      when(mocked.methodCallHandler(any))
          .thenAnswer((final _) async => MethodCallHandler.renewResult);

      final result = await MethodChannelAuth0FlutterAuth().renew(
          ApiRequest<AuthRenewOptions>(
              account: const Account('test-domain', 'test-clientId'),
              userAgent: UserAgent(name: 'test-name', version: 'test-version'),
              options: AuthRenewOptions(refreshToken: 'test-refresh-token')));

      expect(result.accessToken, MethodCallHandler.renewResult['accessToken']);
      expect(result.idToken, MethodCallHandler.renewResult['idToken']);
      expect(
          result.refreshToken, MethodCallHandler.renewResult['refreshToken']);
      expect(result.scopes, MethodCallHandler.renewResult['scopes']);
      expect(result.expiresAt,
          DateTime.parse(MethodCallHandler.renewResult['expiresAt'] as String));
      expect(result.user.name,
          MethodCallHandler.renewResult['userProfile']['name']);
    });

    test('throws an ApiException when method channel returns null', () async {
      when(mocked.methodCallHandler(any)).thenAnswer((final _) async => null);

      Future<Credentials> actual() async {
        final result = await MethodChannelAuth0FlutterAuth().renew(
            ApiRequest<AuthRenewOptions>(
                account: const Account('test-domain', 'test-clientId'),
                userAgent:
                    UserAgent(name: 'test-name', version: 'test-version'),
                options: AuthRenewOptions(refreshToken: 'test-refresh-token')));

        return result;
      }

      await expectLater(actual, throwsA(isA<ApiException>()));
    });

    test(
        'throws an ApiException when method channel throws a PlatformException',
        () async {
      when(mocked.methodCallHandler(any))
          .thenThrow(PlatformException(code: '123'));

      Future<Credentials> actual() async {
        final result = await MethodChannelAuth0FlutterAuth().renew(
            ApiRequest<AuthRenewOptions>(
                account: const Account('test-domain', 'test-clientId'),
                userAgent:
                    UserAgent(name: 'test-name', version: 'test-version'),
                options: AuthRenewOptions(refreshToken: 'test-refresh-token')));

        return result;
      }

      await expectLater(actual, throwsA(isA<ApiException>()));
    });
  });

  group('userInfo', () {
    test('calls the correct MethodChannel method', () async {
      when(mocked.methodCallHandler(any))
          .thenAnswer((final _) async => {'sub': 'test-id'});

      await MethodChannelAuth0FlutterAuth().userInfo(ApiRequest(
          account: const Account('test-domain', 'test-clientId'),
          userAgent: UserAgent(name: 'test-name', version: 'test-version'),
          options: AuthUserInfoOptions(
              accessToken: 'test-token', parameters: {'test': 'test-123'})));

      expect(
          verify(mocked.methodCallHandler(captureAny)).captured.single.method,
          'auth#userInfo');
    });

    test('correctly maps all properties', () async {
      when(mocked.methodCallHandler(any)).thenAnswer((final _) async => {
            'sub': 'test-id',
            'email': 'test-email',
            'nickname': 'test-nickname',
            'family_name': 'test-family-name'
          });

      await MethodChannelAuth0FlutterAuth().userInfo(ApiRequest(
          account: const Account('test-domain', 'test-clientId'),
          userAgent: UserAgent(name: 'test-name', version: 'test-version'),
          options: AuthUserInfoOptions(
              accessToken: 'test-token', parameters: {'test': 'test-123'})));

      final verificationResult =
          verify(mocked.methodCallHandler(captureAny)).captured.single;
      expect(verificationResult.arguments['_account']['domain'], 'test-domain');
      expect(verificationResult.arguments['_account']['clientId'],
          'test-clientId');
      expect(verificationResult.arguments['_userAgent']['name'], 'test-name');
      expect(verificationResult.arguments['_userAgent']['version'],
          'test-version');
      expect(verificationResult.arguments['accessToken'], 'test-token');
      expect(verificationResult.arguments['parameters']['test'], 'test-123');
    });

    test('correctly returns the response from the Method Channel', () async {
      when(mocked.methodCallHandler(any)).thenAnswer((final _) async => {
            'sub': 'test-id',
            'name': 'test-name',
            'given_name': 'test-given-name',
            'family_name': 'test-family-name',
            'middle_name': 'test-middle-name',
            'nickname': 'test-nickname',
            'preferred_username': 'test-preferred-username',
            'profile': 'https://www.google.com',
            'picture': 'https://www.okta.com',
            'website': 'https://www.auth0.com',
            'email': 'test-email',
            'email_verified': true,
            'gender': 'test-gender',
            'birthdate': 'test-birthdate',
            'zoneinfo': 'test-zoneinfo',
            'locale': 'test-locale',
            'phone_number': '123456789',
            'phone_number_verified': true,
            'address': {'country': 'us'},
            'updated_at': '2022-04-01',
            'custom_claims': {'test3': 'test3!'}
          });

      final result = await MethodChannelAuth0FlutterAuth().userInfo(ApiRequest(
          account: const Account('test-domain', 'test-clientId'),
          userAgent: UserAgent(name: 'test-name', version: 'test-version'),
          options: AuthUserInfoOptions(accessToken: 'test-token')));

      verify(mocked.methodCallHandler(captureAny));

      expect(result.sub, 'test-id');
      expect(result.name, 'test-name');
      expect(result.givenName, 'test-given-name');
      expect(result.familyName, 'test-family-name');
      expect(result.middleName, 'test-middle-name');
      expect(result.nickname, 'test-nickname');
      expect(result.preferredUsername, 'test-preferred-username');
      expect(result.profileUrl, Uri.parse('https://www.google.com'));
      expect(result.pictureUrl, Uri.parse('https://www.okta.com'));
      expect(result.websiteUrl, Uri.parse('https://www.auth0.com'));
      expect(result.email, 'test-email');
      expect(result.isEmailVerified, true);
      expect(result.gender, 'test-gender');
      expect(result.birthdate, 'test-birthdate');
      expect(result.zoneinfo, 'test-zoneinfo');
      expect(result.locale, 'test-locale');
      expect(result.phoneNumber, '123456789');
      expect(result.isPhoneNumberVerified, true);
      expect(result.address?['country'], 'us');
      expect(result.updatedAt, DateTime.parse('2022-04-01'));
      expect(result.customClaims?['test3'], 'test3!');
    });

    test(
        'correctly returns the response from the Method Channel when properties missing',
        () async {
      when(mocked.methodCallHandler(any)).thenAnswer(
          (final _) async => {'sub': 'test-id', 'updated_at': '2022-04-01'});

      final result = await MethodChannelAuth0FlutterAuth().userInfo(ApiRequest(
          account: const Account('test-domain', 'test-clientId'),
          userAgent: UserAgent(name: 'test-name', version: 'test-version'),
          options: AuthUserInfoOptions(accessToken: 'test-token')));

      verify(mocked.methodCallHandler(captureAny));

      expect(result.sub, 'test-id');
      expect(result.updatedAt, DateTime.parse('2022-04-01'));
    });

    test('throws an ApiException when method channel returns null', () async {
      when(mocked.methodCallHandler(any)).thenAnswer((final _) async => null);

      Future<void> actual() async {
        await MethodChannelAuth0FlutterAuth().userInfo(ApiRequest(
            account: const Account('test-domain', 'test-clientId'),
            userAgent: UserAgent(name: 'test-name', version: 'test-version'),
            options: AuthUserInfoOptions(accessToken: 'test-token')));
      }

      await expectLater(actual, throwsA(isA<ApiException>()));
    });
    test(
        'throws an ApiException when method channel throws a PlatformException',
        () async {
      when(mocked.methodCallHandler(any))
          .thenThrow(PlatformException(code: '123'));

      Future<void> actual() async {
        await MethodChannelAuth0FlutterAuth().userInfo(ApiRequest(
            account: const Account('test-domain', 'test-clientId'),
            userAgent: UserAgent(name: 'test-name', version: 'test-version'),
            options: AuthUserInfoOptions(accessToken: 'test-token')));
      }

      await expectLater(actual, throwsA(isA<ApiException>()));
    });
  });
}
