// coverage: ignore-file

import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

class Auth0ExceptionMatcher<T extends Auth0Exception> extends Matcher {
  final String _code;
  final String _message;

  const Auth0ExceptionMatcher(this._code, this._message);

  @override
  bool matches(final dynamic item, final Map<dynamic, dynamic> matchState) {
    if (item is! T) return false;

    return item.code == _code && item.message == _message;
  }

  @override
  Description describe(final Description description) =>
      description.add(T.runtimeType.toString());
}
