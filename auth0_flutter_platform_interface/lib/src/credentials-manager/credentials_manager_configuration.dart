//
class CredentialsManagerConfiguration {
  IOSCredentialsConfiguration? iosConfiguration;
  AndroidCredentialsConfiguration? androidConfiguration;

  CredentialsManagerConfiguration(
      {this.iosConfiguration, this.androidConfiguration});

  Map<String, dynamic> toMap() => {
      'ios': iosConfiguration?.toMap(),
      'android': androidConfiguration?.toMap(),
    }..removeWhere((final key, final value) => value == null);
}

class IOSCredentialsConfiguration {
  String storeKey;
  String accessGroup;
  Accessibility accessibility;

  IOSCredentialsConfiguration(this.storeKey, this.accessGroup,this.accessibility);

  Map<String, dynamic> toMap() => {
      'storeKey': storeKey,
      'accessGroup': accessGroup,
    'accessibility': accessibility.name,
    }..removeWhere((final key, final value) => value == null);
}

class AndroidCredentialsConfiguration {
  String sharedPreferenceName;

  AndroidCredentialsConfiguration(this.sharedPreferenceName);

  Map<String, dynamic> toMap() => {
      'sharedPreferencesName': sharedPreferenceName,
    }..removeWhere((final key, final value) => value == null);
}


enum Accessibility {
  afterFirstUnlock,
  afterFirstUnlockThisDeviceOnly,
  whenPasscodeSetThisDeviceOnly,
  whenUnlocked,
  whenUnlockedThisDeviceOnly
}
