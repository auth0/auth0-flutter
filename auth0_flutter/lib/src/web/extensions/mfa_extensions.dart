import 'dart:js_interop';

import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';

import '../js_interop.dart' as interop;

/// Maps the `factorType` discriminant expected by auth0-spa-js' `mfa.enroll`
/// for phone factors.
extension PhoneTypeWebExtension on PhoneType {
  String toWebFactorType() {
    switch (this) {
      case PhoneType.voice:
        return 'voice';
      case PhoneType.sms:
        return 'sms';
    }
  }
}

/// Maps a JS `Authenticator` object from auth0-spa-js into the
/// platform-agnostic [MfaAuthenticator] model.
extension MfaAuthenticatorWebExtension on MfaAuthenticator {
  static MfaAuthenticator fromWeb(final interop.MfaAuthenticatorJS js) =>
      MfaAuthenticator(
        id: js.id,
        type: js.type,
        authenticatorType: js.authenticatorType,
        active: js.active ?? false,
        oobChannel: js.oobChannel,
        name: js.name,
      );
}

/// Maps a JS `EnrollmentResponse` (OTP or OOB) into [MfaEnrollmentChallenge].
extension MfaEnrollmentChallengeWebExtension on MfaEnrollmentChallenge {
  static MfaEnrollmentChallenge fromWeb(
          final interop.MfaEnrollmentResponse js) =>
      MfaEnrollmentChallenge(
        authenticatorType: js.authenticatorType,
        oobChannel: js.oobChannel,
        oobCode: js.oobCode,
        bindingMethod: js.bindingMethod,
        totpSecret: js.secret,
        barcodeUri: js.barcodeUri,
        recoveryCodes:
            js.recoveryCodes?.toDart.map((final e) => e.toDart).toList(),
        id: js.id,
      );
}

/// Maps a JS `ChallengeResponse` into [MfaChallenge].
extension MfaChallengeWebExtension on MfaChallenge {
  static MfaChallenge fromWeb(final interop.MfaChallengeResponse js) =>
      MfaChallenge(
        challengeType: js.challengeType,
        oobCode: js.oobCode,
        bindingMethod: js.bindingMethod,
      );
}
