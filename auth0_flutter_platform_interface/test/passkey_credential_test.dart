import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PasskeyAuthenticatorResponse', () {
    test('toMap includes assertion (login) properties', () {
      const response = PasskeyAuthenticatorResponse(
        clientDataJSON: 'client-data',
        authenticatorData: 'authenticator-data',
        signature: 'signature',
        userHandle: 'user-handle',
      );

      final map = response.toMap();

      expect(map['clientDataJSON'], 'client-data');
      expect(map['authenticatorData'], 'authenticator-data');
      expect(map['signature'], 'signature');
      expect(map['userHandle'], 'user-handle');
      expect(map.containsKey('attestationObject'), isFalse);
    });

    test('toMap includes attestation (signup) properties', () {
      const response = PasskeyAuthenticatorResponse(
        clientDataJSON: 'client-data',
        attestationObject: 'attestation-object',
      );

      final map = response.toMap();

      expect(map['clientDataJSON'], 'client-data');
      expect(map['attestationObject'], 'attestation-object');
      expect(map.containsKey('authenticatorData'), isFalse);
      expect(map.containsKey('signature'), isFalse);
    });

    test('fromMap parses assertion properties', () {
      final response = PasskeyAuthenticatorResponse.fromMap(const {
        'clientDataJSON': 'client-data',
        'authenticatorData': 'authenticator-data',
        'signature': 'signature',
        'userHandle': 'user-handle',
      });

      expect(response.clientDataJSON, 'client-data');
      expect(response.authenticatorData, 'authenticator-data');
      expect(response.signature, 'signature');
      expect(response.userHandle, 'user-handle');
      expect(response.attestationObject, isNull);
    });

    test('fromMap parses attestation properties', () {
      final response = PasskeyAuthenticatorResponse.fromMap(const {
        'clientDataJSON': 'client-data',
        'attestationObject': 'attestation-object',
      });

      expect(response.clientDataJSON, 'client-data');
      expect(response.attestationObject, 'attestation-object');
      expect(response.authenticatorData, isNull);
      expect(response.signature, isNull);
    });

    test('fromMap tolerates a missing userHandle', () {
      final response = PasskeyAuthenticatorResponse.fromMap(const {
        'clientDataJSON': 'client-data',
        'authenticatorData': 'authenticator-data',
        'signature': 'signature',
      });

      expect(response.userHandle, isNull);
    });
  });

  group('PasskeyCredential', () {
    const credential = PasskeyCredential(
      id: 'credential-id',
      rawId: 'raw-id',
      type: 'public-key',
      authenticatorAttachment: 'platform',
      response: PasskeyAuthenticatorResponse(
        clientDataJSON: 'client-data',
        authenticatorData: 'authenticator-data',
        signature: 'signature',
        userHandle: 'user-handle',
      ),
    );

    test('toMap includes the nested response', () {
      final map = credential.toMap();

      expect(map['id'], 'credential-id');
      expect(map['rawId'], 'raw-id');
      expect(map['type'], 'public-key');
      expect(map['authenticatorAttachment'], 'platform');
      final response = map['response'] as Map<String, dynamic>;
      expect(response['clientDataJSON'], 'client-data');
      expect(response['signature'], 'signature');
    });

    test('fromMap parses the nested response', () {
      final parsed = PasskeyCredential.fromMap(const {
        'id': 'credential-id',
        'rawId': 'raw-id',
        'type': 'public-key',
        'authenticatorAttachment': 'platform',
        'response': {
          'clientDataJSON': 'client-data',
          'authenticatorData': 'authenticator-data',
          'signature': 'signature',
          'userHandle': 'user-handle',
        },
      });

      expect(parsed.id, 'credential-id');
      expect(parsed.rawId, 'raw-id');
      expect(parsed.type, 'public-key');
      expect(parsed.authenticatorAttachment, 'platform');
      expect(parsed.response.clientDataJSON, 'client-data');
      expect(parsed.response.authenticatorData, 'authenticator-data');
      expect(parsed.response.signature, 'signature');
      expect(parsed.response.userHandle, 'user-handle');
    });

    test('survives a toMap/fromMap round trip', () {
      final parsed = PasskeyCredential.fromMap(credential.toMap());

      expect(parsed.id, credential.id);
      expect(parsed.rawId, credential.rawId);
      expect(parsed.response.clientDataJSON,
          credential.response.clientDataJSON);
      expect(parsed.response.signature, credential.response.signature);
    });

    test('defaults type to public-key when missing', () {
      final parsed = PasskeyCredential.fromMap(const {
        'id': 'credential-id',
        'rawId': 'raw-id',
        'response': {
          'clientDataJSON': 'client-data',
          'attestationObject': 'attestation-object',
        },
      });

      expect(parsed.type, 'public-key');
      expect(parsed.response.attestationObject, 'attestation-object');
    });
  });
}
