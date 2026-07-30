import 'dart:js_interop';

import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';

import '../js_interop.dart' as interop;

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
        userMetadata: userMetadata?.jsify() as JSObject?,
        realm: connection,
        organization: organization,
      );
}

extension PasskeyLoginChallengeOptionsExtension
    on WebPasskeyLoginChallengeOptions {
  interop.PasskeyLoginChallengeParams toInterop() =>
      interop.PasskeyLoginChallengeParams(
        realm: realm,
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
