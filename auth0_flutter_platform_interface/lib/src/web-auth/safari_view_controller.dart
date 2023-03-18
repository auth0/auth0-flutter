/// Presentation styles for when using SFSafariViewController on iOS.
/// For the full description of what each option does, please see the
/// [UIModelPresentationStyle docs](https://developer.apple.com/documentation/uikit/uimodalpresentationstyle).
enum SafariViewControllerPresentationStyle {
  automatic(-2),
  none(-1),
  fullScreen(0),
  pageSheet(1),
  formSheet(2),
  currentContext(3),
  custom(4),
  overFullScreen(5),
  overCurrentContext(6),
  popover(7);

  const SafariViewControllerPresentationStyle(this.value);
  final int value;
}

/// Configuration for using `SFSafariViewController` on iOS.
class SafariViewController {
  /// The presentation style used when opening the browser window.
  ///
  /// Defaults to `fullScreen`.
  final SafariViewControllerPresentationStyle? presentationStyle;

  const SafariViewController({this.presentationStyle});

  Map<String, dynamic> toMap() =>
      {'presentationStyle': presentationStyle?.value};
}
