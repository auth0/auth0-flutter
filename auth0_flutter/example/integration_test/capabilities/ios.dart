import 'dart:io';

final Map<String, dynamic> iosCapabilities = {
  'platformName': 'ios',
  'platformVersion': '15.4',
  'deviceName': 'iPhone 12 Pro',
  'automationName': 'Flutter',
  'reduceMotion': true,
  'app': File('build/ios/iphonesimulator/Runner.app').absolute.path,
};
