import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart'
    hide PasskeyAuthenticatorResponse, PasskeyChallenge, PasskeyCredential;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'authentication_api_test.mocks.dart';

class TestPlatform extends Mock
    with
        // ignore: prefer_mixin
        MockPlatformInterfaceMixin
    implements
        Auth0FlutterAuthPlatform {
  static DatabaseUser signupResult =
      DatabaseUser(email: 'email', isEmailVerified: true);

  static Credentials loginResult = Credentials.fromMap({
    'accessToken': 'accessToken',
    'idToken': 'idToken',
    'refreshToken': 'refreshToken',
    'expiresAt': DateTime.now().toIso8601String(),
    'scopes': ['a', 'b'],
    'userProfile': {'sub': '123', 'name': 'John Doe'},
    'tokenType': 'Bearer'
  });

  static Challenge multifactorChallengeResult =
      Challenge(type: ChallengeType.oob, oobCode: 'oobCode');

  static Credentials renewResult = Credentials.fromMap({
    'accessToken': 'accessToken',
    'idToken': 'idToken',
    'refreshToken': 'refreshToken',
    'expiresAt': DateTime.now().toIso8601String(),
    'scopes': ['a', 'b'],
    'userProfile': {'sub': '123', 'name': 'John Doe'},
    'tokenType': 'Bearer'
  });

  static const SSOCredentials ssoExchangeResult = SSOCredentials(
    sessionTransferToken: 'sso-token',
    tokenType: 'session_transfer',
    expiresIn: 60,
    idToken: 'id-token',
    refreshToken: 'new-refresh-token',
  );

  static const PasskeyChallenge passkeyLoginChallengeResult = PasskeyChallenge(
    authSession: 'test-auth-session',
    authParamsPublicKey: {
      'challenge': 'test-challenge',
      'rpId': 'test-rp-id',
    },
  );

  static const PasskeyCredential passkeyLoginCredential = PasskeyCredential(
    id: 'test-credential-id',
    rawId: 'test-raw-id',
    type: 'public-key',
    authenticatorAttachment: 'platform',
    response: PasskeyAuthenticatorResponse(
      clientDataJSON: 'test-client-data',
      authenticatorData: 'test-authenticator-data',
      signature: 'test-signature',
      userHandle: 'test-user-handle',
    ),
  );

  static const PasskeyChallenge passkeySignupChallengeResult = PasskeyChallenge(
    authSession: 'test-auth-session',
    authParamsPublicKey: {
      'challenge': 'test-challenge',
      'rpId': 'test-rp-id',
      'userId': 'test-user-id',
      'userName': 'test-user-name',
    },
  );

  static const PasskeyCredential passkeySignupCredential = PasskeyCredential(
    id: 'test-credential-id',
    rawId: 'test-raw-id',
    type: 'public-key',
    authenticatorAttachment: 'platform',
    response: PasskeyAuthenticatorResponse(
      clientDataJSON: 'test-client-data',
      attestationObject: 'test-attestation',
    ),
  );
}

@GenerateMocks([TestPlatform])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final mockedPlatform = MockTestPlatform();

  setUp(() {
    Auth0FlutterAuthPlatform.instance = mockedPlatform;
    reset(mockedPlatform);
  });

  group('signup', () {
    test('passes through properties to the platform', () async {
      when(mockedPlatform.signup(any))
          .thenAnswer((final _) async => TestPlatform.signupResult);

      final result = await Auth0('test-domain', 'test-clientId').api.signup(
        email: 'test-email',
        password: 'test-pass',
        connection: 'test-realm',
        userMetadata: {'test': 'test-123'},
      );

      final verificationResult = verify(mockedPlatform.signup(captureAny))
          .captured
          .single as ApiRequest<AuthSignupOptions>;
      expect(verificationResult.account.domain, 'test-domain');
      expect(verificationResult.account.clientId, 'test-clientId');
      expect(verificationResult.options.email, 'test-email');
      expect(verificationResult.options.password, 'test-pass');
      expect(verificationResult.options.connection, 'test-realm');
      expect(verificationResult.options.userMetadata['test'], 'test-123');
      expect(result, TestPlatform.signupResult);
    });

    test('set userMetadata to default value when omitted', () async {
      when(mockedPlatform.signup(any))
          .thenAnswer((final _) async => TestPlatform.signupResult);

      final result = await Auth0('test-domain', 'test-clientId').api.signup(
            email: 'test-email',
            password: 'test-pass',
            connection: 'test-realm',
          );

      final verificationResult = verify(mockedPlatform.signup(captureAny))
          .captured
          .single as ApiRequest<AuthSignupOptions>;
      expect(verificationResult.options.userMetadata, isEmpty);
      expect(result, TestPlatform.signupResult);
    });
  });

  group('login', () {
    test('passes through properties to the platform', () async {
      when(mockedPlatform.login(any))
          .thenAnswer((final _) async => TestPlatform.loginResult);

      final result = await Auth0('test-domain', 'test-clientId').api.login(
          usernameOrEmail: 'test-user',
          password: 'test-pass',
          connectionOrRealm: 'test-realm',
          audience: 'test-audience',
          scopes: {'test-scope1', 'test-scope2'},
          parameters: {'test': 'test-parameter'});

      final verificationResult = verify(mockedPlatform.login(captureAny))
          .captured
          .single as ApiRequest<AuthLoginOptions>;
      expect(verificationResult.account.domain, 'test-domain');
      expect(verificationResult.account.clientId, 'test-clientId');
      expect(verificationResult.options.usernameOrEmail, 'test-user');
      expect(verificationResult.options.password, 'test-pass');
      expect(verificationResult.options.connectionOrRealm, 'test-realm');
      expect(verificationResult.options.audience, 'test-audience');
      expect(verificationResult.options.scopes, {'test-scope1', 'test-scope2'});
      expect(verificationResult.options.parameters['test'], 'test-parameter');
      expect(result, TestPlatform.loginResult);
    });

    test('set scope and parameters to default value when omitted', () async {
      when(mockedPlatform.login(any))
          .thenAnswer((final _) async => TestPlatform.loginResult);

      final result = await Auth0('test-domain', 'test-clientId').api.login(
          usernameOrEmail: 'test-user',
          password: 'test-pass',
          connectionOrRealm: 'test-realm');

      final verificationResult = verify(mockedPlatform.login(captureAny))
          .captured
          .single as ApiRequest<AuthLoginOptions>;
      expect(verificationResult.options.scopes,
          ['openid', 'profile', 'email', 'offline_access']);
      expect(verificationResult.options.parameters, isEmpty);
      expect(result, TestPlatform.loginResult);
    });

    test('set audience to null when omitted', () async {
      when(mockedPlatform.login(any))
          .thenAnswer((final _) async => TestPlatform.loginResult);

      await Auth0('test-domain', 'test-clientId').api.login(
          usernameOrEmail: 'test-user',
          password: 'test-pass',
          connectionOrRealm: 'test-realm');

      final verificationResult = verify(mockedPlatform.login(captureAny))
          .captured
          .single as ApiRequest<AuthLoginOptions>;
      expect(verificationResult.options.audience, null);
    });
  });

  group('loginWithOtp', () {
    test('passes through properties to the platform', () async {
      when(mockedPlatform.loginWithOtp(any))
          .thenAnswer((final _) async => TestPlatform.loginResult);

      final result = await Auth0('test-domain', 'test-clientId')
          .api
          .loginWithOtp(otp: 'test-otp', mfaToken: 'test-mfa-token');

      final verificationResult = verify(mockedPlatform.loginWithOtp(captureAny))
          .captured
          .single as ApiRequest<AuthLoginWithOtpOptions>;
      expect(verificationResult.account.domain, 'test-domain');
      expect(verificationResult.account.clientId, 'test-clientId');
      expect(verificationResult.options.mfaToken, 'test-mfa-token');
      expect(verificationResult.options.otp, 'test-otp');
      expect(result, TestPlatform.loginResult);
    });
  });

  group('multifactorChallenge', () {
    test('passes through properties to the platform', () async {
      when(mockedPlatform.multifactorChallenge(any)).thenAnswer(
          (final _) async => TestPlatform.multifactorChallengeResult);

      final result = await Auth0('test-domain', 'test-clientId')
          .api
          .multifactorChallenge(
              mfaToken: 'test-mfa-token',
              types: [ChallengeType.otp, ChallengeType.oob],
              authenticatorId: 'test-authenticatorId');

      final verificationResult =
          verify(mockedPlatform.multifactorChallenge(captureAny))
              .captured
              .single as ApiRequest<AuthMultifactorChallengeOptions>;
      expect(verificationResult.account.domain, 'test-domain');
      expect(verificationResult.account.clientId, 'test-clientId');
      expect(verificationResult.options.mfaToken, 'test-mfa-token');
      expect(verificationResult.options.types,
          [ChallengeType.otp, ChallengeType.oob]);
      expect(
          verificationResult.options.authenticatorId, 'test-authenticatorId');
      expect(result, TestPlatform.multifactorChallengeResult);
    });

    test('set parameters to default value when omitted', () async {
      when(mockedPlatform.multifactorChallenge(any)).thenAnswer(
          (final _) async => TestPlatform.multifactorChallengeResult);

      await Auth0('', '').api.multifactorChallenge(mfaToken: '');

      final verificationResult =
          verify(mockedPlatform.multifactorChallenge(captureAny))
              .captured
              .single as ApiRequest<AuthMultifactorChallengeOptions>;
      expect(verificationResult.options.types, isNull);
      expect(verificationResult.options.authenticatorId, isNull);
    });
  });

  group('resetPassword', () {
    test('passes through properties to the platform', () async {
      when(mockedPlatform.resetPassword(any)).thenAnswer((final _) async => {});

      await Auth0('test-domain', 'test-clientId').api.resetPassword(
          email: 'test-user',
          connection: 'test-connection',
          parameters: {'test': 'test-parameter'});

      final verificationResult =
          verify(mockedPlatform.resetPassword(captureAny)).captured.single;
      expect(verificationResult.account.domain, 'test-domain');
      expect(verificationResult.account.clientId, 'test-clientId');
      expect(verificationResult.options.email, 'test-user');
      expect(verificationResult.options.connection, 'test-connection');
      expect(verificationResult.options.parameters['test'], 'test-parameter');
    });

    test('set parameters to default value when omitted', () async {
      when(mockedPlatform.resetPassword(any)).thenAnswer((final _) async => {});

      await Auth0('test-domain', 'test-clientId')
          .api
          .resetPassword(email: 'test-user', connection: 'test-connection');

      final verificationResult =
          verify(mockedPlatform.resetPassword(captureAny)).captured.single;
      expect(verificationResult.options.parameters, isEmpty);
    });
  });

  group('renewCredentials', () {
    test('passes through properties to the platform', () async {
      when(mockedPlatform.renew(any))
          .thenAnswer((final _) async => TestPlatform.renewResult);

      final result = await Auth0('test-domain', 'test-clientId')
          .api
          .renewCredentials(
              refreshToken: 'test-refresh-token',
              scopes: {'test-scope1', 'test-scope2'},
              parameters: {'test': 'test-123'});

      final verificationResult = verify(mockedPlatform.renew(captureAny))
          .captured
          .single as ApiRequest<AuthRenewOptions>;
      expect(verificationResult.account.domain, 'test-domain');
      expect(verificationResult.account.clientId, 'test-clientId');
      expect(verificationResult.options.refreshToken, 'test-refresh-token');
      expect(verificationResult.options.scopes, {'test-scope1', 'test-scope2'});
      expect(verificationResult.options.parameters, {'test': 'test-123'});
      expect(result, TestPlatform.renewResult);
    });

    test('set scope and parameters to default value when omitted', () async {
      when(mockedPlatform.renew(any))
          .thenAnswer((final _) async => TestPlatform.renewResult);

      final result = await Auth0('test-domain', 'test-clientId')
          .api
          .renewCredentials(refreshToken: 'test-refresh-token');

      final verificationResult = verify(mockedPlatform.renew(captureAny))
          .captured
          .single as ApiRequest<AuthRenewOptions>;
      expect(verificationResult.options.scopes, isEmpty);
      expect(verificationResult.options.parameters, isEmpty);
      expect(result, TestPlatform.renewResult);
    });
  });

  group('ssoExchange', () {
    test('passes through properties to the platform', () async {
      when(mockedPlatform.ssoExchange(any))
          .thenAnswer((final _) async => TestPlatform.ssoExchangeResult);

      final result = await Auth0('test-domain', 'test-clientId')
          .api
          .ssoExchange(
              refreshToken: 'test-refresh-token',
              parameters: {'param1': 'value1'},
              headers: {'X-Custom': 'custom-value'});

      final verificationResult = verify(mockedPlatform.ssoExchange(captureAny))
          .captured
          .single as ApiRequest<AuthSSOExchangeOptions>;
      expect(verificationResult.account.domain, 'test-domain');
      expect(verificationResult.account.clientId, 'test-clientId');
      expect(verificationResult.options.refreshToken, 'test-refresh-token');
      expect(verificationResult.options.parameters['param1'], 'value1');
      expect(verificationResult.options.headers['X-Custom'], 'custom-value');
      expect(result, TestPlatform.ssoExchangeResult);
    });

    test('sets parameters and headers to empty maps when omitted', () async {
      when(mockedPlatform.ssoExchange(any))
          .thenAnswer((final _) async => TestPlatform.ssoExchangeResult);

      await Auth0('test-domain', 'test-clientId')
          .api
          .ssoExchange(refreshToken: 'test-refresh-token');

      final verificationResult = verify(mockedPlatform.ssoExchange(captureAny))
          .captured
          .single as ApiRequest<AuthSSOExchangeOptions>;
      expect(verificationResult.options.parameters, isEmpty);
      expect(verificationResult.options.headers, isEmpty);
    });
  });

  group('customTokenExchange', () {
    test('passes actor token and type through to the platform', () async {
      when(mockedPlatform.customTokenExchange(any))
          .thenAnswer((final _) async => TestPlatform.loginResult);

      await Auth0('test-domain', 'test-clientId').api.customTokenExchange(
            subjectToken: 'subject-token',
            subjectTokenType: 'urn:acme:legacy-token',
            actor: const ActorToken(
              token: 'actor-token',
              tokenType: 'urn:ietf:params:oauth:token-type:id_token',
            ),
          );

      final verificationResult =
          verify(mockedPlatform.customTokenExchange(captureAny))
              .captured
              .single as ApiRequest<AuthCustomTokenExchangeOptions>;
      expect(verificationResult.options.actor?.token, 'actor-token');
      expect(verificationResult.options.actor?.tokenType,
          'urn:ietf:params:oauth:token-type:id_token');
    });

    test('leaves actor null when omitted', () async {
      when(mockedPlatform.customTokenExchange(any))
          .thenAnswer((final _) async => TestPlatform.loginResult);

      await Auth0('test-domain', 'test-clientId').api.customTokenExchange(
            subjectToken: 'subject-token',
            subjectTokenType: 'urn:acme:legacy-token',
          );

      final verificationResult =
          verify(mockedPlatform.customTokenExchange(captureAny))
              .captured
              .single as ApiRequest<AuthCustomTokenExchangeOptions>;
      expect(verificationResult.options.actor, isNull);
    });
  });

  group('userInfo', () {
    test('passes through properties to the platform', () async {
      when(mockedPlatform.userInfo(any))
          .thenAnswer((final _) async => const UserProfile(sub: 'sub'));

      await Auth0('test-domain', 'test-clientId')
          .api
          .userProfile(accessToken: 'test-token');

      final verificationResult =
          verify(mockedPlatform.userInfo(captureAny)).captured.single;
      expect(verificationResult.account.domain, 'test-domain');
      expect(verificationResult.account.clientId, 'test-clientId');
      expect(verificationResult.options?.accessToken, 'test-token');
    });

    test('set parameters to default value when omitted', () async {
      when(mockedPlatform.userInfo(any))
          .thenAnswer((final _) async => const UserProfile(sub: 'sub'));

      await Auth0('test-domain', 'test-clientId')
          .api
          .userProfile(accessToken: 'test-token');

      final verificationResult =
          verify(mockedPlatform.userInfo(captureAny)).captured.single;
      expect(verificationResult.options.parameters, isEmpty);
    });

    test('defaults tokenType to Bearer when not specified', () async {
      when(mockedPlatform.userInfo(any))
          .thenAnswer((final _) async => const UserProfile(sub: 'sub'));

      await Auth0('test-domain', 'test-clientId')
          .api
          .userProfile(accessToken: 'test-token');

      final verificationResult =
          verify(mockedPlatform.userInfo(captureAny)).captured.single;
      expect(verificationResult.options.tokenType, 'Bearer');
    });

    test('passes through custom tokenType to the platform', () async {
      when(mockedPlatform.userInfo(any))
          .thenAnswer((final _) async => const UserProfile(sub: 'sub'));

      await Auth0('test-domain', 'test-clientId')
          .api
          .userProfile(accessToken: 'test-token', tokenType: 'DPoP');

      final verificationResult =
          verify(mockedPlatform.userInfo(captureAny)).captured.single;
      expect(verificationResult.account.domain, 'test-domain');
      expect(verificationResult.account.clientId, 'test-clientId');
      expect(verificationResult.options?.accessToken, 'test-token');
      expect(verificationResult.options?.tokenType, 'DPoP');
    });
  });

  group('passkeyLoginChallenge', () {
    test('passes through properties to the platform', () async {
      when(mockedPlatform.passkeyLoginChallenge(any)).thenAnswer(
          (final _) async => TestPlatform.passkeyLoginChallengeResult);

      final result = await Auth0('test-domain', 'test-clientId')
          .api
          .passkeyLoginChallenge(
              connection: 'test-connection', organization: 'test-org');

      final verificationResult =
          verify(mockedPlatform.passkeyLoginChallenge(captureAny))
              .captured
              .single as ApiRequest<AuthPasskeyLoginChallengeOptions>;
      expect(verificationResult.account.domain, 'test-domain');
      expect(verificationResult.account.clientId, 'test-clientId');
      expect(verificationResult.options.connection, 'test-connection');
      expect(verificationResult.options.organization, 'test-org');
      expect(result, TestPlatform.passkeyLoginChallengeResult);
    });

    test('sets connection and organization to null when omitted', () async {
      when(mockedPlatform.passkeyLoginChallenge(any)).thenAnswer(
          (final _) async => TestPlatform.passkeyLoginChallengeResult);

      await Auth0('test-domain', 'test-clientId').api.passkeyLoginChallenge();

      final verificationResult =
          verify(mockedPlatform.passkeyLoginChallenge(captureAny))
              .captured
              .single as ApiRequest<AuthPasskeyLoginChallengeOptions>;
      expect(verificationResult.options.connection, isNull);
      expect(verificationResult.options.organization, isNull);
    });
  });

  group('passkeyCredentialExchange', () {
    test('passes through properties to the platform with login credential',
        () async {
      when(mockedPlatform.passkeyCredentialExchange(any))
          .thenAnswer((final _) async => TestPlatform.loginResult);

      final result = await Auth0('test-domain', 'test-clientId')
          .api
          .passkeyCredentialExchange(
            challenge: TestPlatform.passkeyLoginChallengeResult,
            credential: TestPlatform.passkeyLoginCredential,
            connection: 'test-connection',
            audience: 'test-audience',
            scopes: {'test-scope1', 'test-scope2'},
            organization: 'test-org',
            parameters: {'test': 'test-parameter'},
          );

      final verificationResult =
          verify(mockedPlatform.passkeyCredentialExchange(captureAny))
              .captured
              .single as ApiRequest<AuthPasskeyExchangeOptions>;
      expect(verificationResult.account.domain, 'test-domain');
      expect(verificationResult.account.clientId, 'test-clientId');
      expect(verificationResult.options.challenge.authSession,
          'test-auth-session');
      expect(verificationResult.options.credential.id, 'test-credential-id');
      expect(verificationResult.options.connection, 'test-connection');
      expect(verificationResult.options.audience, 'test-audience');
      expect(verificationResult.options.scopes, {'test-scope1', 'test-scope2'});
      expect(verificationResult.options.organization, 'test-org');
      expect(verificationResult.options.parameters['test'], 'test-parameter');
      expect(result, TestPlatform.loginResult);
    });

    test('uses default scopes and empty params/null fields when omitted',
        () async {
      when(mockedPlatform.passkeyCredentialExchange(any))
          .thenAnswer((final _) async => TestPlatform.loginResult);

      await Auth0('test-domain', 'test-clientId').api.passkeyCredentialExchange(
            challenge: TestPlatform.passkeyLoginChallengeResult,
            credential: TestPlatform.passkeyLoginCredential,
          );

      final verificationResult =
          verify(mockedPlatform.passkeyCredentialExchange(captureAny))
              .captured
              .single as ApiRequest<AuthPasskeyExchangeOptions>;
      expect(verificationResult.options.scopes,
          {'openid', 'profile', 'email', 'offline_access'});
      expect(verificationResult.options.parameters, isEmpty);
      expect(verificationResult.options.connection, isNull);
      expect(verificationResult.options.audience, isNull);
      expect(verificationResult.options.organization, isNull);
    });

    test('passes through properties to the platform with signup credential',
        () async {
      when(mockedPlatform.passkeyCredentialExchange(any))
          .thenAnswer((final _) async => TestPlatform.loginResult);

      final result = await Auth0('test-domain', 'test-clientId')
          .api
          .passkeyCredentialExchange(
            challenge: TestPlatform.passkeySignupChallengeResult,
            credential: TestPlatform.passkeySignupCredential,
            connection: 'test-connection',
            audience: 'test-audience',
            scopes: {'test-scope1', 'test-scope2'},
            organization: 'test-org',
            parameters: {'test': 'test-parameter'},
          );

      final verificationResult =
          verify(mockedPlatform.passkeyCredentialExchange(captureAny))
              .captured
              .single as ApiRequest<AuthPasskeyExchangeOptions>;
      expect(verificationResult.account.domain, 'test-domain');
      expect(verificationResult.account.clientId, 'test-clientId');
      expect(verificationResult.options.challenge.authSession,
          'test-auth-session');
      expect(verificationResult.options.credential.id, 'test-credential-id');
      expect(verificationResult.options.connection, 'test-connection');
      expect(verificationResult.options.audience, 'test-audience');
      expect(verificationResult.options.scopes, {'test-scope1', 'test-scope2'});
      expect(verificationResult.options.organization, 'test-org');
      expect(verificationResult.options.parameters['test'], 'test-parameter');
      expect(result, TestPlatform.loginResult);
    });
  });

  group('passkeySignupChallenge', () {
    test('passes through properties to the platform', () async {
      when(mockedPlatform.passkeySignupChallenge(any)).thenAnswer(
          (final _) async => TestPlatform.passkeySignupChallengeResult);

      final result = await Auth0('test-domain', 'test-clientId')
          .api
          .passkeySignupChallenge(
        email: 'test-email',
        phoneNumber: 'test-phone',
        username: 'test-username',
        name: 'test-name',
        givenName: 'test-given-name',
        familyName: 'test-family-name',
        nickname: 'test-nickname',
        picture: 'https://www.okta.com',
        connection: 'test-connection',
        organization: 'test-org',
        userMetadata: {'plan': 'gold'},
      );

      final verificationResult =
          verify(mockedPlatform.passkeySignupChallenge(captureAny))
              .captured
              .single as ApiRequest<AuthPasskeySignupChallengeOptions>;
      expect(verificationResult.account.domain, 'test-domain');
      expect(verificationResult.options.email, 'test-email');
      expect(verificationResult.options.phoneNumber, 'test-phone');
      expect(verificationResult.options.username, 'test-username');
      expect(verificationResult.options.name, 'test-name');
      expect(verificationResult.options.givenName, 'test-given-name');
      expect(verificationResult.options.familyName, 'test-family-name');
      expect(verificationResult.options.nickname, 'test-nickname');
      expect(verificationResult.options.picture, 'https://www.okta.com');
      expect(verificationResult.options.connection, 'test-connection');
      expect(verificationResult.options.organization, 'test-org');
      expect(verificationResult.options.userMetadata, {'plan': 'gold'});
      expect(result, TestPlatform.passkeySignupChallengeResult);
    });
  });
}
