/// Class used to set platform-specific configuration for
/// CredentialsManager in the SDK.
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


/// Configuration options for the iOS platform that can be set while
/// instantiating the CredentialsManager. It can be used to set the keychain
/// store key,access group and accessibility level for the stored credentials.
class IOSCredentialsConfiguration {
  /// Defaults to "credentials"
  String? storeKey;
  /// Defaults to nil
  String? accessGroup;
  /// Defaults to [Accessibility.afterFirstUnlock]
  Accessibility? accessibility;

  IOSCredentialsConfiguration(
      {this.storeKey, this.accessGroup, this.accessibility});

  Map<String, dynamic> toMap() => {
        'storeKey': storeKey,
        'accessGroup': accessGroup,
        'accessibility': accessibility?.name,
      }..removeWhere((final key, final value) => value == null);
}

/// Configuration options for the Android platform that can be set while
/// instantiating the CredentialsManager.
class AndroidCredentialsConfiguration {
  String sharedPreferenceName;

  AndroidCredentialsConfiguration(this.sharedPreferenceName);

  Map<String, dynamic> toMap() => {
        'sharedPreferencesName': sharedPreferenceName,
      }..removeWhere((final key, final value) => value == null);
}

/// The accessibility level for the credentials on iOS.
enum Accessibility {
  afterFirstUnlock,
  afterFirstUnlockThisDeviceOnly,
  whenPasscodeSetThisDeviceOnly,
  whenUnlocked,
  whenUnlockedThisDeviceOnly
}
