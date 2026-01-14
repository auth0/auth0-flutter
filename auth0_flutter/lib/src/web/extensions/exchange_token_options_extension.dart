import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';
import '../js_interop.dart' as interop;
import '../js_interop_utils.dart';

extension ExchangeTokenOptionsExtension on ExchangeTokenOptions {
  interop.ExchangeTokenOptions toInteropExchangeTokenOptions() {
    final scopeString = scopes.isNotEmpty ? scopes.join(' ') : null;

    final options = JsInteropUtils.stripNulls(interop.ExchangeTokenOptions(
      subject_token: subjectToken,
      subject_token_type: subjectTokenType,
      audience: audience,
      scope: scopeString,
      organization: organizationId,
    ));

    // Add custom parameters if provided
    if (parameters.isNotEmpty) {
      JsInteropUtils.addCustomParams(options, parameters);
    }
    return options;
  }
}
