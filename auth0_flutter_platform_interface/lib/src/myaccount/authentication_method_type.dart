/// The type of authentication method, used to filter results when listing
/// authentication methods via `getAuthenticationMethods`.
enum AuthenticationMethodType {
  password,
  passkey,
  totp,
  phone,
  email,
  pushNotification,
  recoveryCode,
  webAuthnPlatform,
  webAuthnRoaming;

  String toValue() {
    switch (this) {
      case AuthenticationMethodType.password:
        return 'password';
      case AuthenticationMethodType.passkey:
        return 'passkey';
      case AuthenticationMethodType.totp:
        return 'totp';
      case AuthenticationMethodType.phone:
        return 'phone';
      case AuthenticationMethodType.email:
        return 'email';
      case AuthenticationMethodType.pushNotification:
        return 'push-notification';
      case AuthenticationMethodType.recoveryCode:
        return 'recovery-code';
      case AuthenticationMethodType.webAuthnPlatform:
        return 'webauthn-platform';
      case AuthenticationMethodType.webAuthnRoaming:
        return 'webauthn-roaming';
    }
  }

  static AuthenticationMethodType? fromValue(final String? value) {
    switch (value) {
      case 'password':
        return AuthenticationMethodType.password;
      case 'passkey':
        return AuthenticationMethodType.passkey;
      case 'totp':
        return AuthenticationMethodType.totp;
      case 'phone':
        return AuthenticationMethodType.phone;
      case 'email':
        return AuthenticationMethodType.email;
      case 'push-notification':
        return AuthenticationMethodType.pushNotification;
      case 'recovery-code':
        return AuthenticationMethodType.recoveryCode;
      case 'webauthn-platform':
        return AuthenticationMethodType.webAuthnPlatform;
      case 'webauthn-roaming':
        return AuthenticationMethodType.webAuthnRoaming;
      default:
        return null;
    }
  }
}
