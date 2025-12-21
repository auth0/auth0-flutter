import 'package:flutter_test/flutter_test.dart';
import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:auth0_flutter/auth0_flutter_platform_interface.dart';
import 'package:auth0_flutter/auth0_flutter_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAuth0FlutterPlatform
    with MockPlatformInterfaceMixin
    implements Auth0FlutterPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final Auth0FlutterPlatform initialPlatform = Auth0FlutterPlatform.instance;

  test('$MethodChannelAuth0Flutter is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelAuth0Flutter>());
  });

  test('getPlatformVersion', () async {
    final Auth0Flutter auth0FlutterPlugin = Auth0Flutter();
    final MockAuth0FlutterPlatform fakePlatform = MockAuth0FlutterPlatform();
    Auth0FlutterPlatform.instance = fakePlatform;

    expect(await auth0FlutterPlugin.getPlatformVersion(), '42');
  });
}
