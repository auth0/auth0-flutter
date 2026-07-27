import 'dart:js_interop';

import 'package:web/web.dart' as web;

Future<Object?> createPasskeyCredential(final Object authParamsPublicKey) =>
    web.window.navigator.credentials
        .create(web.CredentialCreationOptions(
            publicKey:
                authParamsPublicKey as web.PublicKeyCredentialCreationOptions))
        .toDart;

Future<Object?> getPasskeyCredential(final Object authParamsPublicKey) =>
    web.window.navigator.credentials
        .get(web.CredentialRequestOptions(
            publicKey:
                authParamsPublicKey as web.PublicKeyCredentialRequestOptions))
        .toDart;
