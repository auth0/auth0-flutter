import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PasskeyAuthenticatorAssertionResponse', () {
    test('toMap includes all properties', () {
      const response = PasskeyAuthenticatorAssertionResponse(
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
    });

    test('fromMap parses all properties', () {
      final response = PasskeyAuthenticatorAssertionResponse.fromMap(const {
        'clientDataJSON': 'client-data',
        'authenticatorData': 'authenticator-data',
        'signature': 'signature',
        'userHandle': 'user-handle',
      });

      expect(response.clientDataJSON, 'client-data');
      expect(response.authenticatorData, 'authenticator-data');
      expect(response.signature, 'signature');
      expect(response.userHandle, 'user-handle');
    });

    test('fromMap tolerates a missing userHandle', () {
      final response = PasskeyAuthenticatorAssertionResponse.fromMap(const {
        'clientDataJSON': 'client-data',
        'authenticatorData': 'authenticator-data',
        'signature': 'signature',
      });

      expect(response.userHandle, isNull);
    });
  });

  group('PasskeyLoginCredential', () {
    const credential = PasskeyLoginCredential(
      id: 'credential-id',
      rawId: 'raw-id',
      type: 'public-key',
      authenticatorAttachment: 'platform',
      response: PasskeyAuthenticatorAssertionResponse(
        clientDataJSON: 'client-data',
        authenticatorData: 'authenticator-data',
        signature: 'signature',
        userHandle: 'user-handle',
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
      expect(map['response']['signature'], 'signature');
    });

    test('fromMap parses all properties including the nested response', () {
      final parsed = PasskeyLoginCredential.fromMap(const {
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
        'clientExtensionResults': {'credProps': true},
      });

      expect(parsed.id, 'credential-id');
      expect(parsed.rawId, 'raw-id');
      expect(parsed.type, 'public-key');
      expect(parsed.authenticatorAttachment, 'platform');
      expect(parsed.response.clientDataJSON, 'client-data');
      expect(parsed.response.signature, 'signature');
      expect(parsed.clientExtensionResults?['credProps'], true);
    });

    test('survives a toMap/fromMap round-trip', () {
      final parsed = PasskeyLoginCredential.fromMap(credential.toMap());

      expect(parsed.id, credential.id);
      expect(parsed.rawId, credential.rawId);
      expect(parsed.type, credential.type);
      expect(parsed.authenticatorAttachment,
          credential.authenticatorAttachment);
      expect(parsed.response.clientDataJSON,
          credential.response.clientDataJSON);
      expect(parsed.response.userHandle, credential.response.userHandle);
    });

    test('fromMap defaults type to public-key when missing', () {
      final parsed = PasskeyLoginCredential.fromMap(const {
        'id': 'credential-id',
        'rawId': 'raw-id',
        'response': {
          'clientDataJSON': 'client-data',
          'authenticatorData': 'authenticator-data',
          'signature': 'signature',
        },
      });

      expect(parsed.type, 'public-key');
      expect(parsed.authenticatorAttachment, isNull);
      expect(parsed.clientExtensionResults, isNull);
    });
  });
}
