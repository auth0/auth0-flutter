import 'dart:js_util';

import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';
import 'dart:js';

extension WebExceptionExtentions on WebException {
  static WebException fromJsObject(final Object jsException) => WebException(
      getProperty(jsException, 'error'),
      getProperty(jsException, 'error_description'));
}
