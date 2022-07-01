/// Configuration settings for local authentication prompts.
class LocalAuthenticationOptions {
  /// Title to display on the local authentication prompt. **This is required on iOS**.
  final String? title;

  /// (Android only): Description to display on the local authentication prompt.
  final String? description;

  /// (iOS only): Cancel message to display on the local authentication prompt.
  final String? cancelTitle;

  /// (iOS only): Fallback message to display on the local authentication prompt after a failed match.
  final String? fallbackTitle;

  LocalAuthenticationOptions(
      {this.title, this.description, this.cancelTitle, this.fallbackTitle});
}
