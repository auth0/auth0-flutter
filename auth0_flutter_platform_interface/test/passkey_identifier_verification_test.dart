import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

ApiException _apiException(final Map<String, dynamic> details) =>
    ApiException.fromPlatformException(
        PlatformException(code: 'invalid_grant', details: details));

void main() {
  group('PasskeyVerificationMethod', () {
    test('has the values used by the Authentication API', () {
      expect(PasskeyVerificationMethod.email.value, 'email');
      expect(PasskeyVerificationMethod.phone.value, 'phone');
    });

    test('converts known values and drops unknown ones', () {
      expect(
          PasskeyVerificationMethod.fromValues(['phone', 'unknown', 'email']),
          [PasskeyVerificationMethod.phone, PasskeyVerificationMethod.email]);
    });
  });

  group('PasskeyChallenge', () {
    const publicKey = {'challenge': 'test-challenge', 'rpId': 'test-rp-id'};

    test('has no identifiers to verify when the key is absent', () {
      final challenge = PasskeyChallenge.fromMap({
        'authSession': 'test-auth-session',
        'authParamsPublicKey': publicKey
      });

      expect(challenge.verificationRequired, isNull);
      expect(challenge.toMap(), isNot(contains('verificationRequired')));
    });

    test('reads the identifiers to verify', () {
      final challenge = PasskeyChallenge.fromMap({
        'authSession': 'test-auth-session',
        'authParamsPublicKey': publicKey,
        'verificationRequired': ['email', 'phone'],
      });

      expect(challenge.verificationRequired,
          [PasskeyVerificationMethod.email, PasskeyVerificationMethod.phone]);
    });

    test('writes the identifiers to verify', () {
      const challenge = PasskeyChallenge(
        authSession: 'test-auth-session',
        authParamsPublicKey: publicKey,
        verificationRequired: [PasskeyVerificationMethod.phone],
      );

      expect(challenge.toMap()['verificationRequired'], ['phone']);
    });
  });

  group('AuthPasskeySignupChallengeOptions', () {
    test('maps the delivery method', () {
      expect(AuthPasskeySignupChallengeOptions().toMap()['deliveryMethod'],
          isNull);
      expect(
          AuthPasskeySignupChallengeOptions(deliveryMethod: DeliveryMethod.text)
              .toMap()['deliveryMethod'],
          'text');
    });
  });

  group('AuthPasskeyExchangeOptions', () {
    const challenge = PasskeyChallenge(
        authSession: 'test-auth-session', authParamsPublicKey: {});
    const credential = PasskeyCredential(
        id: 'id',
        rawId: 'raw-id',
        type: 'public-key',
        response: PasskeyAuthenticatorResponse(clientDataJSON: 'data'));

    test('maps no verification codes to an empty map', () {
      final options = AuthPasskeyExchangeOptions(
          challenge: challenge, credential: credential);

      expect(options.toMap()['verification'], isEmpty);
    });

    test('maps the verification codes by identifier', () {
      final options = AuthPasskeyExchangeOptions(
          challenge: challenge,
          credential: credential,
          verification: {PasskeyVerificationMethod.email: '123456'});

      expect(options.toMap()['verification'], {'email': '123456'});
    });
  });

  group('ApiException passkey identifier verification', () {
    test('is not retryable by default', () {
      final exception = _apiException({});

      expect(exception.isPasskeyVerificationRetryable, false);
      expect(exception.passkeyAuthSession, isNull);
      expect(exception.passkeyVerificationRequired, isNull);
    });

    test('exposes the session and identifiers of a retryable error', () {
      final exception = _apiException({
        '_errorFlags': {'isPasskeyVerificationRetryable': true},
        'auth_session': 'test-auth-session',
        'verification_required': ['email'],
      });

      expect(exception.isPasskeyVerificationRetryable, true);
      expect(exception.passkeyAuthSession, 'test-auth-session');
      expect(exception.passkeyVerificationRequired,
          [PasskeyVerificationMethod.email]);
    });

    test('drops identifiers it does not know', () {
      final exception = _apiException({
        '_errorFlags': {'isPasskeyVerificationRetryable': true},
        'auth_session': 'test-auth-session',
        'verification_required': ['email', 'unknown'],
      });

      expect(exception.passkeyVerificationRequired,
          [PasskeyVerificationMethod.email]);
    });

    test('does not expose the identifiers unless the error is retryable', () {
      final exception = _apiException({
        '_errorFlags': {'isPasskeyVerificationRetryable': false},
        'verification_required': ['email'],
      });

      expect(exception.passkeyVerificationRequired, isNull);
    });

    test('is independent of isRetryable and isVerificationRequired', () {
      final exception = _apiException({
        '_errorFlags': {'isPasskeyVerificationRetryable': true},
      });

      expect(exception.isRetryable, false);
      expect(exception.isVerificationRequired, false);
    });
  });

  group('WebException passkey identifier verification', () {
    test('is not retryable by default', () {
      final exception = WebException.passkeyError('code', 'message');

      expect(exception.isPasskeyVerificationRetryable, false);
      expect(exception.passkeyAuthSession, isNull);
      expect(exception.passkeyVerificationRequired, isNull);
    });

    test('exposes the session and identifiers of a retryable error', () {
      final exception = WebException.passkeyError('code', 'message', {
        'isPasskeyVerificationRetryable': true,
        'auth_session': 'test-auth-session',
        'verification_required': ['email', 'phone'],
      });

      expect(exception.isPasskeyVerificationRetryable, true);
      expect(exception.passkeyAuthSession, 'test-auth-session');
      expect(exception.passkeyVerificationRequired,
          [PasskeyVerificationMethod.email, PasskeyVerificationMethod.phone]);
    });

    test('does not expose the identifiers unless the error is retryable', () {
      final exception = WebException.passkeyError('code', 'message', {
        'isPasskeyVerificationRetryable': false,
        'verification_required': ['email'],
      });

      expect(exception.passkeyVerificationRequired, isNull);
    });
  });

  group('web options', () {
    test('default to no verification', () {
      expect(
          WebGetTokenByPasskeyOptions(authSession: 's', authResponse: 'r')
              .verification,
          isEmpty);
      expect(WebPasskeySignupChallengeOptions().deliveryMethod, isNull);
      expect(
          const WebPasskeyChallenge(authSession: 's', authParamsPublicKey: 'k')
              .verificationRequired,
          isNull);
    });
  });
}
