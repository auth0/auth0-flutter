import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PasskeyAuthenticatorAttestationResponse', () {
    test('toMap includes all properties', () {
      const response = PasskeyAuthenticatorAttestationResponse(
        clientDataJSON: 'client-data',
        attestationObject: 'attestation',
      );

      final map = response.toMap();

      expect(map['clientDataJSON'], 'client-data');
      expect(map['attestationObject'], 'attestation');
    });

    test('fromMap parses all properties', () {
      final response = PasskeyAuthenticatorAttestationResponse.fromMap(const {
        'clientDataJSON': 'client-data',
        'attestationObject': 'attestation',
      });

      expect(response.clientDataJSON, 'client-data');
      expect(response.attestationObject, 'attestation');
    });
  });

  group('PasskeySignupCredential', () {
    const credential = PasskeySignupCredential(
      id: 'credential-id',
      rawId: 'raw-id',
      type: 'public-key',
      authenticatorAttachment: 'platform',
      response: PasskeyAuthenticatorAttestationResponse(
        clientDataJSON: 'client-data',
        attestationObject: 'attestation',
      ),
      clientExtensionResults: {'credProps': true},
    );

    test('toMap includes all properties and a nested response map', () {
      final map = credential.toMap();

      expect(map['id'], 'credential-id');
      expect(map['rawId'], 'raw-id');
      expect(map['type'], 'public-key');
      expect(map['authenticatorAttachment'], 'platform');
      expect(map['clientExtensionResults'], {'credProps': true});
      expect(map['response'], isA<Map<String, dynamic>>());
      expect(map['response']['attestationObject'], 'attestation');
    });

    test('fromMap parses all properties including the nested response', () {
      final parsed = PasskeySignupCredential.fromMap(const {
        'id': 'credential-id',
        'rawId': 'raw-id',
        'type': 'public-key',
        'authenticatorAttachment': 'platform',
        'response': {
          'clientDataJSON': 'client-data',
          'attestationObject': 'attestation',
        },
        'clientExtensionResults': {'credProps': true},
      });

      expect(parsed.id, 'credential-id');
      expect(parsed.rawId, 'raw-id');
      expect(parsed.type, 'public-key');
      expect(parsed.authenticatorAttachment, 'platform');
      expect(parsed.response.clientDataJSON, 'client-data');
      expect(parsed.response.attestationObject, 'attestation');
      expect(parsed.clientExtensionResults?['credProps'], true);
    });

    test('survives a toMap/fromMap round-trip', () {
      final parsed = PasskeySignupCredential.fromMap(credential.toMap());

      expect(parsed.id, credential.id);
      expect(parsed.rawId, credential.rawId);
      expect(parsed.type, credential.type);
      expect(parsed.authenticatorAttachment,
          credential.authenticatorAttachment);
      expect(parsed.response.clientDataJSON,
          credential.response.clientDataJSON);
      expect(parsed.response.attestationObject,
          credential.response.attestationObject);
    });

    test('fromMap defaults type to public-key when missing', () {
      final parsed = PasskeySignupCredential.fromMap(const {
        'id': 'credential-id',
        'rawId': 'raw-id',
        'response': {
          'clientDataJSON': 'client-data',
          'attestationObject': 'attestation',
        },
      });

      expect(parsed.type, 'public-key');
      expect(parsed.authenticatorAttachment, isNull);
      expect(parsed.clientExtensionResults, isNull);
    });
  });
}
