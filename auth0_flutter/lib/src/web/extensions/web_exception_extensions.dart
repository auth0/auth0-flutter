import 'dart:js_util';
import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';

extension WebExceptionExtension on WebException {
  static WebException fromJsObject(final Object jsException) => WebException(
      getProperty(jsException, 'error'),
      getProperty(jsException, 'error_description'));
}
