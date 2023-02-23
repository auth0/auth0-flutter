/// Settings for local authentication prompts.
class LocalAuthentication {
  /// Title to display on the local authentication prompt. Defaults to **Please
  /// authenticate to continue** on iOS, `null` on Android.
  final String? title;

  /// (Android only): Description to display on the local authentication prompt.
  final String? description;

  /// (iOS only): Cancel message to display on the local authentication prompt.
  final String? cancelTitle;

  /// (iOS only): Fallback message to display on the local authentication prompt
  ///  after a failed match.
  final String? fallbackTitle;

  const LocalAuthentication(
      {this.title, this.description, this.cancelTitle, this.fallbackTitle});
}
