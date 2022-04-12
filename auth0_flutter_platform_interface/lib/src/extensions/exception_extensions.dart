import 'package:flutter/services.dart';

extension ExceptionExtensions on PlatformException {
  String get messageString => message ?? '';

  Map<String, dynamic> get detailsMap =>
      details != null && details is Map<dynamic, dynamic>
          ? Map<String, dynamic>.from(details as Map<dynamic, dynamic>)
          : <String, dynamic>{};
}
