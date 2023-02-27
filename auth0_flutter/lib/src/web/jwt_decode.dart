import 'dart:convert';

import 'jwt_decode_exception.dart';

class JWT {
  static Map<String, dynamic> decode(final String jwt) {
    final parts = jwt.split('.');

    if (parts.length != 3) {
      throw JWTDecodeException.invalidPartCount(jwt, parts.length);
    }

    final String stringPayload;

    try {
      final decodedPayload = base64.decode(base64.normalize(parts[1]));
      stringPayload = utf8.decode(decodedPayload);
    } catch (error) {
      throw JWTDecodeException.invalidBase64URL(parts[1]);
    }

    try {
      return jsonDecode(stringPayload) as Map<String, dynamic>;
    } catch (error) {
      throw JWTDecodeException.invalidJSON(parts[1]);
    }
  }
}
