import 'dart:io';

final Map<String, dynamic> androidCapabilities = {
  'platformName': 'Android',
  'app': File('build/app/outputs/flutter-apk/app-debug.apk').absolute.path,
  'deviceName': 'emulator-5554',
  'automationName': 'Flutter',
};
