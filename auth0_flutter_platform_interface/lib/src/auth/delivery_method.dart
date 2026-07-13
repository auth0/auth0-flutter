/// How a passwordless OTP is delivered when challenging with a phone number.
enum DeliveryMethod {
  /// Deliver the one-time code via SMS text message.
  text('text'),

  /// Deliver the one-time code via a voice call.
  voice('voice');

  final String value;

  const DeliveryMethod(this.value);
}
