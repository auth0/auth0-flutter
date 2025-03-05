import 'dart:js_interop';
import 'dart:js_interop_unsafe';

@JS('Object.keys')
external JSArray<JSString> keys(final JSObject o);

// TODO: remove this extension when updating to Dart 3.6.0
extension JSArrayExt on JSArray<JSString> {
  @JS('length')
  external int get arrayLength;

  @JS('at')
  external JSFunction get elementAt;
}

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

  /// Convert the Javascript object [obj] to a Dart object.
  ///
  /// This method should only be used to convert objects
  /// that do not fit into a static interop definition.
  ///
  /// See https://api.dart.dev/dart-js_interop/JSAnyUtilityExtension/dartify.html
  static Object? dartifyObject(final JSAny? obj) => obj.dartify();

  /// Convert the Dart object [obj] to a plain Javascript object.
  ///
  /// This method should only be used to convert objects
  /// that do not fit into a static interop definition.
  ///
  /// See https://api.dart.dev/dart-js_interop/NullableObjectUtilExtension/jsify.html
  static JSAny? jsifyObject(final Object? obj) => obj.jsify();
}
