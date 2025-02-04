/// Types of passwordless authentication.
enum PasswordlessType {
  /// Simple OTP code sent by email or SMS.
  code('code'),
  /// Regular Web HTTP link (web only, uses a redirect).
  link('link'),
  /// Android App Link.
  linkAndroid('link_android'),
  /// iOS Universal Link.
  linkIOS('link_ios');

  final String name;

  const PasswordlessType(this.name);
}
