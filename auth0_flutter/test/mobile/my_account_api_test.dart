import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class _RecordingPlatform extends Auth0FlutterMyAccountPlatform
    with
        // ignore: prefer_mixin
        MockPlatformInterfaceMixin {
  final List<ApiRequest<RequestOptions>> requests = [];

  static const profile = MyAccountProfile(
    userId: 'auth0|123',
    givenName: 'Jane',
    profilePolicy: {
      '/given_name': ProfileFieldPolicy(
          access: ProfileFieldAccess.readWrite,
          source: ProfileFieldSource.user),
    },
  );

  @override
  Future<MyAccountProfile> getUserProfile(
      ApiRequest<MyAccountGetUserProfileOptions> request) {
    requests.add(request);
    return Future.value(profile);
  }

  @override
  Future<MyAccountProfile> updateUserProfile(
      ApiRequest<MyAccountUpdateUserProfileOptions> request) {
    requests.add(request);
    return Future.value(profile);
  }
}

void main() {
  late _RecordingPlatform platform;

  setUp(() {
    platform = _RecordingPlatform();
    Auth0FlutterMyAccountPlatform.instance = platform;
  });

  MyAccountApi myAccount({bool useDPoP = false}) =>
      Auth0('test-domain', 'test-clientId')
          .myAccount(accessToken: 'access-token', useDPoP: useDPoP);

  group('getUserProfile', () {
    test('passes the access token and default options', () async {
      final result = await myAccount().getUserProfile();

      final request = platform.requests.single;
      final options = request.options as MyAccountGetUserProfileOptions;
      expect(request.account.domain, 'test-domain');
      expect(request.account.clientId, 'test-clientId');
      expect(request.useDPoP, false);
      expect(options.accessToken, 'access-token');
      expect(options.fields, isNull);
      expect(options.includeFields, true);
      expect(result, _RecordingPlatform.profile);
    });

    test('passes fields, includeFields and useDPoP', () async {
      await myAccount(useDPoP: true).getUserProfile(
          fields: ['given_name', 'profile_policy'], includeFields: false);

      final request = platform.requests.single;
      final options = request.options as MyAccountGetUserProfileOptions;
      expect(request.useDPoP, true);
      expect(options.fields, ['given_name', 'profile_policy']);
      expect(options.includeFields, false);
    });
  });

  group('updateUserProfile', () {
    test('passes every provided field', () async {
      final result = await myAccount().updateUserProfile(
          givenName: 'Jane',
          familyName: 'Doe',
          name: 'Jane Doe',
          nickname: 'jane',
          picture: 'https://example.com/jane.png');

      final options =
          platform.requests.single.options as MyAccountUpdateUserProfileOptions;
      expect(options.accessToken, 'access-token');
      expect(options.givenName, 'Jane');
      expect(options.familyName, 'Doe');
      expect(options.name, 'Jane Doe');
      expect(options.nickname, 'jane');
      expect(options.picture, 'https://example.com/jane.png');
      expect(result.givenName, 'Jane');
    });

    test('sends a request even when no field is provided', () async {
      await myAccount().updateUserProfile();

      final options =
          platform.requests.single.options as MyAccountUpdateUserProfileOptions;
      expect(options.givenName, isNull);
      expect(options.familyName, isNull);
      expect(options.name, isNull);
      expect(options.nickname, isNull);
      expect(options.picture, isNull);
    });
  });
}
