import 'dart:js_util';

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
    final T obj,
    final Map<String, dynamic> params,
  ) {
    params.forEach((final key, final value) {
      if (value != null) {
        setProperty(obj, key, value);
      }
    });

    return obj;
  }

  // TODO: replace w/ `dartify` from `dart:js_interop_unsafe` when migrating to WASM
  /// Convert the Javascript object [obj] to a Dart object.
  ///
  /// This method should only be used to convert objects
  /// that do not fit into a static interop definition.
  ///
  /// See https://api.dart.dev/dart-js_interop/JSAnyUtilityExtension/dartify.html
  static Object? dartifyObject(final Object? obj) => dartify(obj);

  // TODO: replace w/ `jsify` from `dart:js_interop_unsafe` when migrating to WASM
  /// Convert the Dart object [obj] to a plain Javascript object.
  ///
  /// This method should only be used to convert objects
  /// that do not fit into a static interop definition.
  ///
  /// See https://api.dart.dev/dart-js_interop/NullableObjectUtilExtension/jsify.html
  static Object? jsifyObject(final Object? obj) => jsify(obj);
}
