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

class SafariViewController {
  final SafariViewControllerPresentationStyle? presentationStyle;

  const SafariViewController({this.presentationStyle});

  Map<String, dynamic> toMap() => {
        ...presentationStyle != null
            ? {'presentationStyle': presentationStyle?.value}
            : <String, dynamic>{}
      };
}
