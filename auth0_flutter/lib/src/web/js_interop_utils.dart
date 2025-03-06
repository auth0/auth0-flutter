import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'js_interop.dart';

@JS('Object.keys')
external JSArray<JSString> keys(final JSObject o);

class JsInteropUtils {
  /// Rebuilds the input object, omitting values that are null
  static T stripNulls<T extends JSObject>(final T obj) {
    final objKeys = keys(obj);
    final output = JSObject();

    for (var i = 0; i < objKeys.arrayLength; i++) {
      // TODO: replace w/ `final key = objKeys[i];` when updating to Dart 3.6.0
      final key = objKeys.elementAt.callAsFunction(objKeys, i.toJS)!;
      final value = obj.getProperty(key);
      if (value != null) {
        output.setProperty(key, value);
      }
    }
    return output as T;
  }

  // Adds arbitrary key/value pairs to the supplied object.
  // **Note**: there is no static typing for these parameters to be able
  // to retrieve them again.
  static T addCustomParams<T extends JSObject>(
    final T obj,
    final Map<String, dynamic> params,
  ) {
    params.forEach((final key, final value) {
      if (value != null) {
        obj.setProperty(key.toJS, value as JSAny);
      }
    });
    return obj;
  }
}
