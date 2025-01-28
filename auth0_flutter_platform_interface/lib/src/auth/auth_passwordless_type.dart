/// Types of passwordless authentication.
enum PasswordlessType {
  /// Simple OTP code sent by email or SMS.
  code,
  /// Regular Web HTTP link (web only, uses a redirect).
  link,
  /// Android App Link.
  link_android,
  /// Universal Link.
  link_ios
}
