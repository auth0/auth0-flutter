enum PhoneType {
  sms,
  voice;

  String toValue() {
    switch (this) {
      case PhoneType.sms:
        return 'sms';
      case PhoneType.voice:
        return 'voice';
    }
  }

  static PhoneType fromValue(final String value) {
    switch (value) {
      case 'sms':
        return PhoneType.sms;
      case 'voice':
        return PhoneType.voice;
      default:
        return PhoneType.sms;
    }
  }
}
