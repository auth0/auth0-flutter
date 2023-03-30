import 'dart:js_util';

import 'js_interop.dart';

class JsInteropUtils {
  /// Rebuilds the input object, omitting values that are null
  static T stripNulls<T extends Object>(final T obj) {
    final keys = objectKeys(obj);
    final output = newObject<Object>();

    for (var i = 0; i < keys.length; i++) {
      final key = keys[i] as String;
      final value = getProperty(obj, key) as dynamic;

      if (value != null) {
        setProperty(output, key, value);
      }
    }

    return output as T;
  }

  // Adds arbitrary key/value pairs to the supplied object.
  // **Note**: there is no static typing for these parameters to be able
  // to retrieve them again.
  static T addCustomParams<T extends Object>(
      final T obj, final Map<String, dynamic> params) {
    params.forEach((final key, final value) {
      if (value != null) {
        setProperty(obj, key, value);
      }
    });

    return obj;
  }
}

extension AuthParamsExtension on AuthorizationParams {
  // Wrapper for common use case of stripping nulls and mixing in parameters
  // on AuthorizationParams.
  AuthorizationParams prepare([final Map<String, dynamic>? params]) =>
      JsInteropUtils.stripNulls(
          JsInteropUtils.addCustomParams(this, params ?? {}));

  // Converts an instance of AuthorizationParams to
  // GetTokenSilentlyAuthorizationParams.
  GetTokenSilentlyAuthParams toGetTokenSilentlyParams() =>
      JsInteropUtils.stripNulls(GetTokenSilentlyAuthParams(
          redirect_uri: redirect_uri, scope: scope, audience: audience));
}
