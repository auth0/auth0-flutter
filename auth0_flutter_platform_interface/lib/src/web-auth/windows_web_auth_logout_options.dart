import 'web_auth_logout_options.dart';

/// Options for performing logout via Universal Login on Windows.
///
/// [appCustomURL] is required. It is the custom-scheme URL (e.g.
/// `auth0flutter://callback`) that the Windows app registers and listens on to
/// receive the post-logout redirect from the browser.
///
/// [returnTo] is optional. When provided, it is used as the `returnTo`
/// parameter in the Auth0 logout URL (e.g. an HTTPS intermediary server).
/// When omitted, [appCustomURL] is used as the `returnTo` value directly.
class WindowsWebAuthLogoutOptions extends WebAuthLogoutOptions {
  final String appCustomURL;

  WindowsWebAuthLogoutOptions({
    required this.appCustomURL,
    super.returnTo,
    super.federated = false,
  });

  @override
  Map<String, dynamic> toMap() => {
        'appCustomURL': appCustomURL,
        'returnTo': returnTo,
        'federated': federated,
      };
}
