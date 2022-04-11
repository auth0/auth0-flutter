// Mocks generated by Mockito 5.1.0 from annotations
// in auth0_flutter/test/authentication_api_test.dart.
// Do not manually edit this file.

import 'dart:async' as _i4;

import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart'
    as _i2;
import 'package:mockito/mockito.dart' as _i1;

import 'authentication_api_test.dart' as _i3;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types

class _FakeCredentials_0 extends _i1.Fake implements _i2.Credentials {}

class _FakeUserProfile_1 extends _i1.Fake implements _i2.UserProfile {}

class _FakeDatabaseUser_2 extends _i1.Fake implements _i2.DatabaseUser {}

/// A class which mocks [TestPlatform].
///
/// See the documentation for Mockito's code generation for more information.
class MockTestPlatform extends _i1.Mock implements _i3.TestPlatform {
  MockTestPlatform() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.Future<_i2.Credentials> login(
          _i2.ApiRequest<_i2.AuthLoginOptions>? request) =>
      (super.noSuchMethod(Invocation.method(#login, [request]),
              returnValue: Future<_i2.Credentials>.value(_FakeCredentials_0()))
          as _i4.Future<_i2.Credentials>);
  @override
  _i4.Future<_i2.UserProfile> userInfo(
          _i2.ApiRequest<_i2.AuthUserInfoOptions>? request) =>
      (super.noSuchMethod(Invocation.method(#userInfo, [request]),
              returnValue: Future<_i2.UserProfile>.value(_FakeUserProfile_1()))
          as _i4.Future<_i2.UserProfile>);
  @override
  _i4.Future<_i2.DatabaseUser> signup(
          _i2.ApiRequest<_i2.AuthSignupOptions>? request) =>
      (super.noSuchMethod(Invocation.method(#signup, [request]),
              returnValue:
                  Future<_i2.DatabaseUser>.value(_FakeDatabaseUser_2()))
          as _i4.Future<_i2.DatabaseUser>);
  @override
  _i4.Future<_i2.Credentials> renewAccessToken(
          _i2.ApiRequest<_i2.AuthRenewAccessTokenOptions>? request) =>
      (super.noSuchMethod(Invocation.method(#renewAccessToken, [request]),
              returnValue: Future<_i2.Credentials>.value(_FakeCredentials_0()))
          as _i4.Future<_i2.Credentials>);
  @override
  _i4.Future<void> resetPassword(
          _i2.ApiRequest<_i2.AuthResetPasswordOptions>? request) =>
      (super.noSuchMethod(Invocation.method(#resetPassword, [request]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i4.Future<void>);
}
