import '../request/request_options.dart';
import 'custom_tabs_options.dart';

class WebAuthLogoutOptions implements RequestOptions {
  final bool useHTTPS;
  final String? returnTo;
  final String? scheme;
  final bool federated;
  final CustomTabsOptions? customTabsOptions;
  @Deprecated('Use CustomTabsOptions.allowedBrowsers instead')
  final List<String> allowedBrowsers;

  WebAuthLogoutOptions(
      {this.useHTTPS = false,
      this.returnTo,
      this.scheme,
      this.federated = false,
      this.customTabsOptions,
      this.allowedBrowsers = const []});

  @override
  Map<String, dynamic> toMap() => {
        'useHTTPS': useHTTPS,
        'returnTo': returnTo,
        'scheme': scheme,
        'federated': federated,
        'allowedBrowsers': allowedBrowsers,
        ...customTabsOptions != null
            ? {'customTabsOptions': customTabsOptions?.toMap()}
            : <String, dynamic>{}
      };
}
