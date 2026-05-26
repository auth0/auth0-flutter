/// Configuration for using Chrome Custom Tabs on Android.
///
/// Supports Partial Custom Tabs (bottom sheet / side sheet) on Chrome 107+.
/// On older browsers, these options are ignored and the tab opens full-screen.
class CustomTabsOptions {
  /// The initial height of the bottom sheet in dp.
  ///
  /// Chrome enforces a minimum of 50% of the screen height.
  final int? initialHeight;

  /// Whether the user can drag to resize the bottom sheet.
  ///
  /// Defaults to `true` when not specified.
  final bool? resizable;

  /// The toolbar's top corner radius in dp.
  ///
  /// Only applies in bottom sheet mode. Values are clamped to [0, 16].
  final int? toolbarCornerRadius;

  /// The initial width of the side sheet in dp.
  ///
  /// Only applies on screens wider than [sideSheetBreakpoint].
  final int? initialWidth;

  /// The dp breakpoint to toggle between bottom sheet and side sheet.
  ///
  /// When the screen width exceeds this value, the tab renders as a side sheet.
  /// If not set, the browser's default (typically 840dp) is used.
  final int? sideSheetBreakpoint;

  /// Whether the user can interact with the app behind the partial tab.
  ///
  /// Defaults to `false` when not specified.
  final bool? backgroundInteractionEnabled;

  /// An allowlist of browser packages to use for Custom Tabs.
  ///
  /// When the user's default browser is in the allowlist, it is used.
  /// When the user's default browser is not in the allowlist but another
  /// allowed browser is installed, that browser is used instead.
  /// When no allowed browser is installed, an error is returned.
  final List<String> allowedBrowsers;

  const CustomTabsOptions({
    this.initialHeight,
    this.resizable,
    this.toolbarCornerRadius,
    this.initialWidth,
    this.sideSheetBreakpoint,
    this.backgroundInteractionEnabled,
    this.allowedBrowsers = const [],
  });

  Map<String, dynamic> toMap() => {
        'initialHeight': initialHeight,
        'resizable': resizable,
        'toolbarCornerRadius': toolbarCornerRadius,
        'initialWidth': initialWidth,
        'sideSheetBreakpoint': sideSheetBreakpoint,
        'backgroundInteractionEnabled': backgroundInteractionEnabled,
        'allowedBrowsers': allowedBrowsers,
      };
}
