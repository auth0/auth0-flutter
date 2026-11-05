/// A server-side validation error returned by the My Account API, typically
/// on a `400` response. See `MyAccountException.validationErrors`.
class MyAccountValidationError {
  /// Information about the validation error.
  final String? detail;

  /// The name of the field that failed validation.
  final String? field;

  /// An RFC 6901 JSON Pointer to the property in the request payload that
  /// failed validation, e.g. `/given_name`.
  final String? pointer;

  /// The location of the property that failed validation, e.g. `body`.
  final String? source;

  const MyAccountValidationError({
    this.detail,
    this.field,
    this.pointer,
    this.source,
  });

  factory MyAccountValidationError.fromMap(final Map<dynamic, dynamic> map) =>
      MyAccountValidationError(
        detail: map['detail'] as String?,
        field: map['field'] as String?,
        pointer: map['pointer'] as String?,
        source: map['source'] as String?,
      );
}
