@Tags(['browser'])
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:auth0_flutter/auth0_flutter_web.dart';
import 'package:auth0_flutter/src/web/auth0_flutter_plugin_real.dart';
import 'package:auth0_flutter/src/web/auth0_flutter_web_platform_proxy.dart';
import 'package:auth0_flutter/src/web/js_interop.dart' as interop;
import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

const _apiBase = 'https://test-domain.auth0.com/me/';
const _accessToken = 'my-account-access-token';

JSObject _jsObject(Map<String, Object?> map) => map.jsify()! as JSObject;

Map<String, Object?> _dartify(JSObject object) =>
    (object.dartify()! as Map).cast<String, Object?>();

final _method = _jsObject({
  'id': 'totp|dev_1',
  'type': 'totp',
  'confirmed': true,
  'created_at': '2026-01-02T03:04:05.000Z',
}) as interop.MyAccountAuthenticationMethodJS;

final _challenge = _jsObject({
  'id': 'totp|dev_1',
  'auth_session': 'session',
  'barcode_uri': 'otpauth://totp/tenant:user?secret=ABC',
  'manual_input_code': 'ABC',
}) as interop.MyAccountEnrollmentChallengeJS;

/// A fake proxy that records the My Account calls made by the plugin and
/// returns canned auth0-spa-js responses.
class _FakeClientProxy extends Auth0FlutterWebClientProxy {
  _FakeClientProxy()
      : super(
            client: JSObject() as interop.Auth0Client,
            myAccountApiBase: _apiBase);

  // Calls recorded as (method, positional-args), with JS params dartified.
  final List<List<Object?>> calls = [];

  /// When set, every call fails with this error.
  Object? error;

  Future<T> _respond<T>(List<Object?> call, T result) {
    calls.add(call);
    final error = this.error;
    return error != null ? Future.error(error) : Future.value(result);
  }

  @override
  Future<JSArray<interop.MyAccountAuthenticationMethodJS>>
      myAccountGetAuthenticationMethods(String accessToken, String? type) =>
          _respond(
              ['getAuthenticationMethods', accessToken, type], [_method].toJS);

  @override
  Future<interop.MyAccountAuthenticationMethodJS>
      myAccountGetAuthenticationMethod(String accessToken, String id) =>
          _respond(['getAuthenticationMethod', accessToken, id], _method);

  @override
  Future<void> myAccountDeleteAuthenticationMethod(
          String accessToken, String id) =>
      _respond(['deleteAuthenticationMethod', accessToken, id], null);

  @override
  Future<interop.MyAccountAuthenticationMethodJS>
      myAccountUpdateAuthenticationMethod(String accessToken, String id,
              interop.MyAccountUpdateAuthenticationMethodParams params) =>
          _respond(
              ['updateAuthenticationMethod', accessToken, id, _dartify(params)],
              _method);

  @override
  Future<JSArray<interop.MyAccountFactorJS>> myAccountGetFactors(
          String accessToken) =>
      _respond(
          ['getFactors', accessToken],
          [
            _jsObject({
              'type': 'phone',
              'usage': ['secondary']
            }) as interop.MyAccountFactorJS
          ].toJS);

  @override
  Future<interop.MyAccountEnrollmentChallengeJS> myAccountEnrollmentChallenge(
          String accessToken,
          interop.MyAccountEnrollmentChallengeParams params) =>
      _respond(
          ['enrollmentChallenge', accessToken, _dartify(params)], _challenge);

  @override
  Future<interop.MyAccountAuthenticationMethodJS> myAccountEnrollmentVerify(
          String accessToken, interop.MyAccountEnrollmentVerifyParams params) =>
      _respond(['enrollmentVerify', accessToken, _dartify(params)], _method);
}

void main() {
  final auth0 = Auth0Web('test-domain', 'test-client-id');
  late Auth0FlutterPlugin plugin;
  late _FakeClientProxy proxy;
  late MyAccountWeb myAccount;

  setUp(() {
    proxy = _FakeClientProxy();
    plugin = Auth0FlutterPlugin();
    plugin.clientProxy = proxy;
    plugin.urlSearchProvider = () => null;
    Auth0FlutterWebPlatform.instance = plugin;
    myAccount = auth0.myAccount(accessToken: _accessToken);
  });

  group('authentication methods', () {
    test('getAuthenticationMethods returns the mapped methods', () async {
      final result = await myAccount.getAuthenticationMethods();

      expect(
          proxy.calls.single, ['getAuthenticationMethods', _accessToken, null]);
      expect(result.single.id, 'totp|dev_1');
      expect(result.single.confirmed, true);
      expect(result.single.createdAt, DateTime.utc(2026, 1, 2, 3, 4, 5));
    });

    test('getAuthenticationMethods sends the type filter value', () async {
      await myAccount.getAuthenticationMethods(
          type: AuthenticationMethodType.pushNotification);

      expect(proxy.calls.single,
          ['getAuthenticationMethods', _accessToken, 'push-notification']);
    });

    test('getAuthenticationMethod sends the id', () async {
      final result = await myAccount.getAuthenticationMethod(id: 'totp|dev_1');

      expect(proxy.calls.single,
          ['getAuthenticationMethod', _accessToken, 'totp|dev_1']);
      expect(result.type, 'totp');
    });

    test('deleteAuthenticationMethod sends the id', () async {
      await myAccount.deleteAuthenticationMethod(id: 'totp|dev_1');

      expect(proxy.calls.single,
          ['deleteAuthenticationMethod', _accessToken, 'totp|dev_1']);
    });

    test('updateAuthenticationMethod sends the name and phone type', () async {
      await myAccount.updateAuthenticationMethod(
          id: 'phone|dev_1',
          name: 'My phone',
          preferredAuthenticationMethod: PhoneType.voice);

      expect(proxy.calls.single, [
        'updateAuthenticationMethod',
        _accessToken,
        'phone|dev_1',
        {'name': 'My phone', 'preferred_authentication_method': 'voice'}
      ]);
    });

    test('updateAuthenticationMethod omits fields that are not provided',
        () async {
      await myAccount.updateAuthenticationMethod(
          id: 'phone|dev_1', name: 'My phone');

      expect(proxy.calls.single[3], {'name': 'My phone'});
    });
  });

  test('getFactors returns the mapped factors', () async {
    final result = await myAccount.getFactors();

    expect(proxy.calls.single, ['getFactors', _accessToken]);
    expect(result.single.type, 'phone');
    expect(result.single.usage, ['secondary']);
  });

  group('enroll', () {
    test('enrollPhone sends the phone number and preferred method', () async {
      await myAccount.enrollPhone(
          phoneNumber: '+15555550100', type: PhoneType.sms);

      expect(proxy.calls.single, [
        'enrollmentChallenge',
        _accessToken,
        {
          'type': 'phone',
          'phone_number': '+15555550100',
          'preferred_authentication_method': 'sms'
        }
      ]);
    });

    test('enrollEmail sends the email', () async {
      await myAccount.enrollEmail(email: 'user@example.com');

      expect(proxy.calls.single[2],
          {'type': 'email', 'email': 'user@example.com'});
    });

    test('enrollTotp sends only the type and maps the challenge', () async {
      final result = await myAccount.enrollTotp();

      expect(proxy.calls.single[2], {'type': 'totp'});
      expect(result.id, 'totp|dev_1');
      expect(result.authSession, 'session');
      expect(result.totpSecret, 'ABC');
      expect(result.totpUri, 'otpauth://totp/tenant:user?secret=ABC');
      expect(result.barcodeUri, 'otpauth://totp/tenant:user?secret=ABC');
    });

    test('enrollPush sends the push-notification type', () async {
      await myAccount.enrollPush();

      expect(proxy.calls.single[2], {'type': 'push-notification'});
    });

    test('enrollRecoveryCode sends the recovery-code type', () async {
      await myAccount.enrollRecoveryCode();

      expect(proxy.calls.single[2], {'type': 'recovery-code'});
    });
  });

  group('confirm', () {
    test('verifyOtp builds the location from the id and sends the otp',
        () async {
      final result = await myAccount.verifyOtp(
          id: 'totp|dev_1',
          authSession: 'session',
          otp: '123456',
          factorType: 'totp');

      expect(proxy.calls.single, [
        'enrollmentVerify',
        _accessToken,
        {
          'type': 'totp',
          'location': '${_apiBase}v1/authentication-methods/totp%7Cdev_1',
          'auth_session': 'session',
          'otp_code': '123456'
        }
      ]);
      expect(result.id, 'totp|dev_1');
    });

    test('confirmEnrollment sends no otp', () async {
      await myAccount.confirmEnrollment(
          id: 'push-notification|dev_1',
          authSession: 'session',
          factorType: 'push-notification');

      expect(proxy.calls.single[2], {
        'type': 'push-notification',
        'location': '${_apiBase}v1/authentication-methods/'
            'push-notification%7Cdev_1',
        'auth_session': 'session'
      });
    });
  });

  group('errors', () {
    test('a MyAccountApiError is thrown as a MyAccountException', () async {
      proxy.error = _jsObject({
        'name': 'MyAccountApiError',
        'type': 'https://auth0.com/api-errors/A0E-401-0001',
        'status': 401,
        'title': 'Unauthorized',
        'detail': 'The access token is invalid',
      });

      await expectLater(
          myAccount.getFactors(),
          throwsA(isA<MyAccountException>()
              .having((e) => e.code, 'code',
                  'https://auth0.com/api-errors/A0E-401-0001')
              .having((e) => e.statusCode, 'statusCode', 401)
              .having((e) => e.title, 'title', 'Unauthorized')
              .having(
                  (e) => e.message, 'message', 'The access token is invalid')));
    });

    test('a network failure is thrown as a retryable MyAccountException',
        () async {
      proxy.error = _jsObject({'name': 'TypeError', 'message': 'Failed'});

      await expectLater(
          myAccount.enrollTotp(),
          throwsA(isA<MyAccountException>()
              .having((e) => e.isNetworkError, 'isNetworkError', true)
              .having((e) => e.isRetryable, 'isRetryable', true)));
    });

    test('a MyAccountException from the proxy is rethrown unchanged', () async {
      const error = MyAccountException.unknown('requires a newer version');
      proxy.error = error;

      await expectLater(myAccount.getAuthenticationMethods(), throwsA(error));
    });

    test('throws when the client has not been initialized', () async {
      plugin.clientProxy = null;

      await expectLater(myAccount.getFactors(), throwsA(isA<ArgumentError>()));
    });
  });

  group('Auth0FlutterWebClientProxy', () {
    // A minimal stand-in for the auth0-spa-js globals used by the proxy:
    // `auth0.MyAccountApiClient` and `Auth0Client.createFetcher`.
    const fakeSpaJs = '''
      window.auth0 = {
        MyAccountApiClient: class {
          constructor(fetcher, apiBase) {
            this.fetcher = fetcher;
            this.apiBase = apiBase;
          }
          async getFactors() {
            const token = await this.fetcher.config.getAccessToken(undefined);
            return [{ type: 'phone', token: token, apiBase: this.apiBase,
                      config: this.fetcher.config }];
          }
        }
      };
      window.__fakeAuth0Client = {
        createFetcher(config) { return { config: config }; }
      };
    ''';

    late JSAny? originalAuth0;

    setUp(() {
      originalAuth0 = globalContext['auth0'];
      globalContext.callMethod('eval'.toJS, fakeSpaJs.toJS);
    });

    tearDown(() {
      if (originalAuth0 == null) {
        globalContext.delete('auth0'.toJS);
      } else {
        globalContext['auth0'] = originalAuth0;
      }
      globalContext.delete('__fakeAuth0Client'.toJS);
    });

    Auth0FlutterWebClientProxy createProxy({required bool useDPoP}) =>
        Auth0FlutterWebClientProxy(
            client: globalContext['__fakeAuth0Client']! as interop.Auth0Client,
            myAccountApiBase: _apiBase,
            useDPoP: useDPoP);

    // Returns the single factor produced by the fake `getFactors`, which
    // echoes the token, API base and fetcher config it was created with.
    Future<JSObject> getFactor(Auth0FlutterWebClientProxy proxy) async {
      final result = await proxy.myAccountGetFactors(_accessToken);
      return result.toDart.single;
    }

    String? stringProperty(JSObject object, String name) =>
        object.getProperty<JSString?>(name.toJS)?.toDart;

    test('authorizes requests with the caller-supplied access token', () async {
      final factor = await getFactor(createProxy(useDPoP: false));

      expect(stringProperty(factor, 'token'), _accessToken);
      expect(stringProperty(factor, 'apiBase'), _apiBase);
    });

    test('configures the fetcher without DPoP by default', () async {
      final factor = await getFactor(createProxy(useDPoP: false));
      final config = factor.getProperty<JSObject>('config'.toJS);

      expect(stringProperty(config, 'baseUrl'), _apiBase);
      expect(config.has('dpopNonceId'), false);
    });

    test('configures the fetcher with the My Account DPoP nonce id', () async {
      final factor = await getFactor(createProxy(useDPoP: true));
      final config = factor.getProperty<JSObject>('config'.toJS);

      expect(stringProperty(config, 'dpopNonceId'), '__auth0_my_account_api__');
    });

    test('throws a MyAccountException when auth0-spa-js is too old', () {
      globalContext['auth0'] = JSObject();

      expect(
          () => createProxy(useDPoP: false).myAccountGetFactors(_accessToken),
          throwsA(isA<MyAccountException>().having((e) => e.message, 'message',
              contains('auth0-spa-js v2.21.1 or later'))));
    });
  });
}
