import 'dart:js_interop';

import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';

import '../js_interop.dart' as interop;

/// Converts [metadata] to a [JSObject], or returns null when the conversion is
/// not possible. Guards against maps whose runtime values do not match their
/// declared `String` type (e.g. a `cast()` view over dynamic JSON), which would
/// otherwise throw from `jsify()`.
JSObject? _jsifyUserMetadata(final Map<String, String>? metadata) {
  if (metadata == null) {
    return null;
  }

  try {
    return metadata.jsify() as JSObject?;
  } catch (_) {
    return null;
  }
}

extension PasskeySignupChallengeOptionsExtension
    on WebPasskeySignupChallengeOptions {
  interop.PasskeySignupChallengeParams toInterop() =>
      interop.PasskeySignupChallengeParams(
        email: email,
        phoneNumber: phoneNumber,
        username: username,
        name: name,
        givenName: givenName,
        familyName: familyName,
        nickname: nickname,
        picture: picture,
        userMetadata: _jsifyUserMetadata(userMetadata),
        realm: connection,
        organization: organization,
      );
}

extension PasskeyLoginChallengeOptionsExtension
    on WebPasskeyLoginChallengeOptions {
  interop.PasskeyLoginChallengeParams toInterop() =>
      interop.PasskeyLoginChallengeParams(
        realm: connection,
        organization: organization,
      );
}

extension PasskeyChallengeResponseExtension
    on interop.PasskeyChallengeResponse {
  WebPasskeyChallenge toWebPasskeyChallenge() => WebPasskeyChallenge(
        authSession: authSession,
        authParamsPublicKey: publicKey,
      );
}
