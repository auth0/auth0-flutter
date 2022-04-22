import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'method_channel_auth0_flutter_auth_test.mocks.dart';

class MethodCallHandler {
  static const Map<dynamic, dynamic> loginResult = {
    'accessToken': 'accessToken',
    'idToken': 'idToken',
    'refreshToken': 'refreshToken',
    'expiresAt': '2022-01-01',
    'scopes': ['a'],
    'userProfile': {'sub': '123', 'name': 'John Doe'}
  };

  static const Map<dynamic, dynamic> renewAccessTokenResult = {
    'accessToken': 'accessToken',
    'idToken': 'idToken',
    'refreshToken': 'refreshToken',
    'expiresAt': '2022-01-01',
    'scopes': ['a'],
    'userProfile': {'sub': '123', 'name': 'John Doe'}
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
      when(mocked.methodCallHandler(any)).thenAnswer((final _) async => {
            'email': 'test-email',
            'emailVerified': true,
            'username': 'test-user'
          });

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
      when(mocked.methodCallHandler(any)).thenAnswer((final _) async => {
            'email': 'test-email',
            'emailVerified': true,
            'username': 'test-user'
          });

      await MethodChannelAuth0FlutterAuth().signup(
          ApiRequest<AuthSignupOptions>(
              account: const Account('test-domain', 'test-clientId'),
              userAgent: UserAgent(name: 'test-name', version: 'test-version'),
              options: AuthSignupOptions(
                  email: 'test-email',
                  password: 'test-pass',
                  connection: 'test-connection',
                  username: 'test-user')));

      final verificationResult =
          verify(mocked.methodCallHandler(captureAny)).captured.single;
      expect(verificationResult.arguments['_account']['domain'], 'test-domain');
      expect(verificationResult.arguments['_account']['clientId'],
          'test-clientId');
      expect(verificationResult.arguments['_userAgent']['name'], 'test-name');
      expect(
          verificationResult.arguments['_userAgent']['version'],
          'test-version');
      expect(verificationResult.arguments['email'], 'test-email');
      expect(verificationResult.arguments['username'], 'test-user');
      expect(verificationResult.arguments['password'], 'test-pass');
      expect(verificationResult.arguments['connection'], 'test-connection');
    });

    test('correctly returns the response from the Method Channel', () async {
      when(mocked.methodCallHandler(any)).thenAnswer((final _) async => {
            'email': 'test-email',
            'emailVerified': true,
            'username': 'test-user'
          });

      final result = await MethodChannelAuth0FlutterAuth().signup(
          ApiRequest<AuthSignupOptions>(
              account: const Account('test-domain', 'test-clientId'),
              userAgent: UserAgent(name: 'test-name', version: 'test-version'),
              options: AuthSignupOptions(
                  email: 'test-email',
                  password: 'test-pass',
                  connection: 'test-connection',
                  username: 'test-user')));

      verify(mocked.methodCallHandler(captureAny));

      expect(result.email, 'test-email');
      expect(result.emailVerified, true);
      expect(result.username, 'test-user');
    });

    test('correctly returns emailVerified when true', () async {
      when(mocked.methodCallHandler(any)).thenAnswer(
          (final _) async => {'email': 'test-email', 'emailVerified': true});

      final result = await MethodChannelAuth0FlutterAuth().signup(
          ApiRequest<AuthSignupOptions>(
              account: const Account('test-domain', 'test-clientId'),
              userAgent: UserAgent(name: 'test-name', version: 'test-version'),
              options:
                  AuthSignupOptions(email: '', password: '', connection: '')));

      verify(mocked.methodCallHandler(captureAny));
      expect(result.emailVerified, true);
    });

    test('correctly returns emailVerified when false', () async {
      when(mocked.methodCallHandler(any)).thenAnswer(
          (final _) async => {'email': 'test-email', 'emailVerified': false});

      final result = await MethodChannelAuth0FlutterAuth().signup(
          ApiRequest<AuthSignupOptions>(
              account: const Account('', ''),
              userAgent: UserAgent(name: 'test-name', version: 'test-version'),
              options:
                  AuthSignupOptions(email: '', password: '', connection: '')));

      verify(mocked.methodCallHandler(captureAny));
      expect(result.emailVerified, false);
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
          throwsA(predicate((e) =>
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
      expect(verificationResult.arguments['scopes'], ['a', 'b']);
      expect(verificationResult.arguments['parameters']['test'], 'test-123');
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
                connectionOrRealm: 'test-connection',
                scopes: {'a', 'b'},
                parameters: {'test': 'test-123'})),
      );

      verify(mocked.methodCallHandler(captureAny));

      expect(result.accessToken, MethodCallHandler.loginResult['accessToken']);
      expect(result.idToken, MethodCallHandler.loginResult['idToken']);
      expect(result.expiresAt,
          DateTime.parse(MethodCallHandler.loginResult['expiresAt'] as String));
      expect(result.scopes, MethodCallHandler.loginResult['scopes']);
      expect(
          result.refreshToken, MethodCallHandler.loginResult['refreshToken']);
      expect(result.userProfile.name,
          MethodCallHandler.loginResult['userProfile']['name']);
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
      expect(
          verificationResult.arguments['_userAgent']['version'],
          'test-version');
      expect(verificationResult.arguments['email'], 'test-email');
      expect(verificationResult.arguments['connection'], 'test-connection');
      expect(verificationResult.arguments['parameters']['test'], 'test-123');
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

  group('renewAccessToken', () {
    test('calls the correct MethodChannel method', () async {
      when(mocked.methodCallHandler(any)).thenAnswer(
          (final _) async => MethodCallHandler.renewAccessTokenResult);

      await MethodChannelAuth0FlutterAuth()
          .renewAccessToken(ApiRequest<AuthRenewAccessTokenOptions>(
              account: const Account('test-domain', 'test-clientId'),
              userAgent: UserAgent(name: 'test-name', version: 'test-version'),
              options: AuthRenewAccessTokenOptions(
                refreshToken: 'test-refresh-token',
              )));

      expect(
          verify(mocked.methodCallHandler(captureAny)).captured.single.method,
          'auth#renewAccessToken');
    });

    test('correctly maps all properties', () async {
      when(mocked.methodCallHandler(any)).thenAnswer(
          (final _) async => MethodCallHandler.renewAccessTokenResult);

      await MethodChannelAuth0FlutterAuth()
          .renewAccessToken(ApiRequest<AuthRenewAccessTokenOptions>(
              account: const Account('test-domain', 'test-clientId'),
              userAgent: UserAgent(name: 'test-name', version: 'test-version'),
              options: AuthRenewAccessTokenOptions(
                refreshToken: 'test-refresh-token',
              )));

      final verificationResult =
          verify(mocked.methodCallHandler(captureAny)).captured.single;
      expect(verificationResult.arguments['_account']['domain'], 'test-domain');
      expect(verificationResult.arguments['_account']['clientId'],
          'test-clientId');
      expect(verificationResult.arguments['_userAgent']['name'], 'test-name');
      expect(
          verificationResult.arguments['_userAgent']['version'],
          'test-version');
      expect(
          verificationResult.arguments['refreshToken'], 'test-refresh-token');
    });

    test('correctly returns the response from the Method Channel', () async {
      when(mocked.methodCallHandler(any)).thenAnswer(
          (final _) async => MethodCallHandler.renewAccessTokenResult);

      final result = await MethodChannelAuth0FlutterAuth()
          .renewAccessToken(ApiRequest<AuthRenewAccessTokenOptions>(
              account: const Account('test-domain', 'test-clientId'),
              userAgent: UserAgent(name: 'test-name', version: 'test-version'),
              options: AuthRenewAccessTokenOptions(
                refreshToken: 'test-refresh-token',
              )));

      expect(result.accessToken,
          MethodCallHandler.renewAccessTokenResult['accessToken']);
      expect(
          result.idToken, MethodCallHandler.renewAccessTokenResult['idToken']);
      expect(result.refreshToken,
          MethodCallHandler.renewAccessTokenResult['refreshToken']);
      expect(result.scopes, MethodCallHandler.renewAccessTokenResult['scopes']);
      expect(
          result.expiresAt,
          DateTime.parse(
              MethodCallHandler.renewAccessTokenResult['expiresAt'] as String));
      expect(result.userProfile.name,
          MethodCallHandler.renewAccessTokenResult['userProfile']['name']);
    });

    test('throws an ApiException when method channel returns null', () async {
      when(mocked.methodCallHandler(any)).thenAnswer((final _) async => null);

      Future<Credentials> actual() async {
        final result = await MethodChannelAuth0FlutterAuth().renewAccessToken(
            ApiRequest<AuthRenewAccessTokenOptions>(
                account: const Account('test-domain', 'test-clientId'),
                userAgent:
                    UserAgent(name: 'test-name', version: 'test-version'),
                options: AuthRenewAccessTokenOptions(
                  refreshToken: 'test-refresh-token',
                )));

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
        final result = await MethodChannelAuth0FlutterAuth().renewAccessToken(
            ApiRequest<AuthRenewAccessTokenOptions>(
                account: const Account('test-domain', 'test-clientId'),
                userAgent:
                    UserAgent(name: 'test-name', version: 'test-version'),
                options: AuthRenewAccessTokenOptions(
                  refreshToken: 'test-refresh-token',
                )));

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
          options: AuthUserInfoOptions(accessToken: 'test-token')));

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
          options: AuthUserInfoOptions(accessToken: 'test-token')));

      final verificationResult =
          verify(mocked.methodCallHandler(captureAny)).captured.single;
      expect(verificationResult.arguments['_account']['domain'], 'test-domain');
      expect(verificationResult.arguments['_account']['clientId'],
          'test-clientId');
      expect(verificationResult.arguments['_userAgent']['name'], 'test-name');
      expect(
          verificationResult.arguments['_userAgent']['version'],
          'test-version');
      expect(verificationResult.arguments['accessToken'], 'test-token');
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
      expect(result.profileURL, Uri.parse('https://www.google.com'));
      expect(result.pictureURL, Uri.parse('https://www.okta.com'));
      expect(result.websiteURL, Uri.parse('https://www.auth0.com'));
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
