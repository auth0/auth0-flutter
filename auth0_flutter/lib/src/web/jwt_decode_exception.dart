import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';

class JWTDecodeException extends Auth0Exception {
  static const _invalidPartCount = 'INVALID_PART_COUNT';
  static const _invalidBase64URL = 'INVALID_BASE64URL';
  static const _invalidJSON = 'INVALID_JSON';

  const JWTDecodeException(final String code, final String message)
      : super(code, message, const {});

  // When either the header or body parts cannot be Base64URL-decoded.
  const JWTDecodeException.invalidBase64URL(final String value)
      : this(JWTDecodeException._invalidBase64URL,
            'Failed to decode Base64URL value $value.');

  // When either the decoded header or body is not a valid JSON object.
  const JWTDecodeException.invalidJSON(final String value)
      : this(JWTDecodeException._invalidJSON,
            'Failed to parse JSON from Base64URL value $value.');

  // When the JWT doesn't have the required amount of parts (header, body, and
  // signature).
  const JWTDecodeException.invalidPartCount(final String jwt, final int parts)
      : this(JWTDecodeException._invalidPartCount,
            'The JWT $jwt has $parts parts when it should have 3 parts.');
}
