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

  /// Whether to launch the browser as a Trusted Web Activity (TWA).
  ///
  /// Defaults to `false`. TWA requires the app to be verified for the Auth0
  /// domain through Digital Asset Links. Takes precedence over [useAuthTab]
  /// when both are `true`.
  final bool useTrustedWebActivity;

  /// Whether to launch the browser as an Auth Tab.
  ///
  /// Auth Tab uses the Chrome Custom Tabs Activity Result API, which avoids
  /// spurious user-cancelled errors caused by Chrome being minimized. It
  /// requires Chrome 137+; older browsers fall back to a standard Custom Tab.
  /// Defaults to `false`. Ignored when [useTrustedWebActivity] is `true`.
  final bool useAuthTab;

  const CustomTabsOptions({
    this.initialHeight,
    this.resizable,
    this.toolbarCornerRadius,
    this.initialWidth,
    this.sideSheetBreakpoint,
    this.backgroundInteractionEnabled,
    this.allowedBrowsers = const [],
    this.useTrustedWebActivity = false,
    this.useAuthTab = false,
  });

  Map<String, dynamic> toMap() => {
        'initialHeight': initialHeight,
        'resizable': resizable,
        'toolbarCornerRadius': toolbarCornerRadius,
        'initialWidth': initialWidth,
        'sideSheetBreakpoint': sideSheetBreakpoint,
        'backgroundInteractionEnabled': backgroundInteractionEnabled,
        'allowedBrowsers': allowedBrowsers,
        'useTrustedWebActivity': useTrustedWebActivity,
        'useAuthTab': useAuthTab,
      };
}
