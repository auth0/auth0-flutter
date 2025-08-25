# Change Log

## [afpi-v1.12.0](https://github.com/auth0/auth0-flutter/tree/afpi-v1.12.0) (2025-07-10)
[Full Changelog](https://github.com/auth0/auth0-flutter/compare/afpi-v1.11.0...afpi-v1.12.0)

**Added**
- chore: added new renewCredentials method to fetch a new set of credentials [\#610](https://github.com/auth0/auth0-flutter/pull/610) ([pmathew92](https://github.com/pmathew92))
- dart api to input allowed browser packages for web auth login [\#611](https://github.com/auth0/auth0-flutter/pull/611) ([NandanPrabhu](https://github.com/NandanPrabhu))
- chore : added new properties to web_authentication_exception and credentials_manager_exception class [\#609](https://github.com/auth0/auth0-flutter/pull/609) ([pmathew92](https://github.com/pmathew92))
- Added webAuth cancel for ios to prevent active transaction errors [\#573](https://github.com/auth0/auth0-flutter/pull/573) ([pmathew92](https://github.com/pmathew92))

## [afpi-v1.11.0](https://github.com/auth0/auth0-flutter/tree/afpi-v1.11.0) (2025-06-11)
[Full Changelog](https://github.com/auth0/auth0-flutter/compare/afpi-v1.10.0...afpi-v1.11.0)

**Added**
- Added support to configure credentials manager for iOS and Android  [\#576](https://github.com/auth0/auth0-flutter/pull/576) ([pmathew92](https://github.com/pmathew92))

## [afpi-v1.10.0](https://github.com/auth0/auth0-flutter/tree/afpi-v1.10.0) (2025-04-29)
[Full Changelog](https://github.com/auth0/auth0-flutter/compare/afpi-v1.9.0...afpi-v1.10.0)

**Added**
- implement app state getter for web [\#509](https://github.com/auth0/auth0-flutter/pull/509) ([navaronbracke](https://github.com/navaronbracke))
- feat(auth): 🔐 Add UserProfile serialization and include in Credentials [\#556](https://github.com/auth0/auth0-flutter/pull/556) ([Rohithgilla12](https://github.com/Rohithgilla12))

**Fixed**
- Fixed the WASM compilation issue on 3.24 version of flutter [\#547](https://github.com/auth0/auth0-flutter/pull/547) ([pmathew92](https://github.com/pmathew92))

## [afpi-v1.9.0](https://github.com/auth0/auth0-flutter/tree/afpi-v1.9.0) (2025-03-05)
[Full Changelog](https://github.com/auth0/auth0-flutter/compare/afpi-v1.8.0...afpi-v1.9.0)

**Added**
- Added support for WASM compilation [\#516](https://github.com/auth0/auth0-flutter/pull/516) ([pmathew92](https://github.com/pmathew92))

**Updated**
- Updated Flutter version to 3.24.0 ([pmathew92](https://github.com/pmathew92))
- Updated Dart sdk version to 3.5.0 ([pmathew92](https://github.com/pmathew92))

## [afpi-v1.8.0](https://github.com/auth0/auth0-flutter/tree/afpi-v1.8.0) (2025-02-10)
[Full Changelog](https://github.com/auth0/auth0-flutter/compare/afpi-v1.7.0...afpi-v1.8.0)

**This release updates the minimum required version for iOS to 14**

**Added**
- feat: Added support for passwordless authentication [\#503](https://github.com/auth0/auth0-flutter/pull/503) ([pmathew92](https://github.com/pmathew92))

**Changed**
- Updated the android gradle version [\#490](https://github.com/auth0/auth0-flutter/pull/490) ([pmathew92](https://github.com/pmathew92))
- Update Swift dependencies [\#493](https://github.com/auth0/auth0-flutter/pull/493) ([Widcket](https://github.com/Widcket))
- Minor readme update [\#483](https://github.com/auth0/auth0-flutter/pull/483) ([pmathew92](https://github.com/pmathew92))
- Set `compileSdk` to `34` to match Auth0.Android [\#494](https://github.com/auth0/auth0-flutter/pull/494) ([Widcket](https://github.com/Widcket))
- Use java.time.Instant instead of java.text.SimpleDateFormat [\#469](https://github.com/auth0/auth0-flutter/pull/469) ([gferon](https://github.com/gferon))

## [afpi-v1.7.0](https://github.com/auth0/auth0-flutter/tree/afpi-v1.7.0) (2024-04-22)
[Full Changelog](https://github.com/auth0/auth0-flutter/compare/afpi-v1.6.0...afpi-v1.7.0)

**Added**
- iOS - Bump Auth0 dependency version [\#435](https://github.com/auth0/auth0-flutter/pull/435) ([martin-headspace](https://github.com/martin-headspace))

## [afpi-v1.6.0](https://github.com/auth0/auth0-flutter/tree/afpi-v1.6.0) (2024-03-18)
[Full Changelog](https://github.com/auth0/auth0-flutter/compare/afpi-v1.5.0...afpi-v1.6.0)

**Added**
- Add support for HTTPS redirect URLs [SDK-4754] [\#417](https://github.com/auth0/auth0-flutter/pull/417) ([Widcket](https://github.com/Widcket))

## [afpi-v1.5.0](https://github.com/auth0/auth0-flutter/tree/afpi-v1.5.0) (2023-12-15)
[Full Changelog](https://github.com/auth0/auth0-flutter/compare/afpi-v1.4.0...afpi-v1.5.0)

**Added**
- Add support for macOS [\#381](https://github.com/auth0/auth0-flutter/pull/381) ([Widcket](https://github.com/Widcket))

## [afpi-v1.4.0](https://github.com/auth0/auth0-flutter/tree/afpi-v1.4.0) (2023-12-06)
[Full Changelog](https://github.com/auth0/auth0-flutter/compare/afpi-v1.3.1...afpi-v1.4.0)

**Added**
- Add support for passing parameters onLoad [\#363](https://github.com/auth0/auth0-flutter/pull/363) ([frederikprijck](https://github.com/frederikprijck))

**Changed**
- Remove and gitignore `pubspec.lock` files [\#340](https://github.com/auth0/auth0-flutter/pull/340) ([Widcket](https://github.com/Widcket))

## [afpi-v1.3.1](https://github.com/auth0/auth0-flutter/tree/afpi-v1.3.1) (2023-11-08)
[Full Changelog](https://github.com/auth0/auth0-flutter/compare/afpi-v1.3.0...afpi-v1.3.1)

**Fixed**
- afpi: Ensure Dart `expiresAt` uses the UTC time zone [\#331](https://github.com/auth0/auth0-flutter/pull/331) ([Widcket](https://github.com/Widcket))

## [afpi-v1.3.0](https://github.com/auth0/auth0-flutter/tree/afpi-v1.3.0) (2023-10-27)
[Full Changelog](https://github.com/auth0/auth0-flutter/compare/v1.2.1...afpi-v1.3.0)

**Changed**
- Lock Auth0.Android version to avoid dynamic versioning [\#311](https://github.com/auth0/auth0-flutter/pull/311) ([poovamraj](https://github.com/poovamraj))
- Add namespace to build.gradle [\#290](https://github.com/auth0/auth0-flutter/pull/290) ([poovamraj](https://github.com/poovamraj))

**Fixed**
- Fix access token expiry android [\#315](https://github.com/auth0/auth0-flutter/pull/315) ([poovamraj](https://github.com/poovamraj))

## [v1.2.1](https://github.com/auth0/auth0-flutter/tree/v1.2.1) (2023-06-06)
[Full Changelog](https://github.com/auth0/auth0-flutter/compare/v1.2.0...v1.2.1)

**Fixed**
- fix: allow audience and scope to be supplied during initialization [\#272](https://github.com/auth0/auth0-flutter/pull/272) ([stevehobbsdev](https://github.com/stevehobbsdev))

## [v1.2.0](https://github.com/auth0/auth0-flutter/tree/v1.2.0) (2023-05-31)
[Full Changelog](https://github.com/auth0/auth0-flutter/compare/v1.1.0...v1.2.0)

This release adds official support for the Web platform! 🎉 Please checkout [the readme](https://github.com/auth0/auth0-flutter/tree/main/auth0_flutter#readme) for full usage instructions for all supported platforms:

Other changes in this release:

**Added**
- Add support for requesting MFA challenges [SDK-4052] [\#251](https://github.com/auth0/auth0-flutter/pull/251) ([Widcket](https://github.com/Widcket))

**Fixed**
- Use Locale.US for Android [\#238](https://github.com/auth0/auth0-flutter/pull/238) ([Mecharyry](https://github.com/Mecharyry))

## [v1.2.0-beta.1](https://github.com/auth0/auth0-flutter/tree/v1.2.0-beta.1) (2023-05-25)

[Full Changelog](https://github.com/auth0/auth0-flutter/compare/v1.2.0-beta.0...v1.2.0-beta.1)

**Fixed**

- Use Locale.US for Android [\#238](https://github.com/auth0/auth0-flutter/pull/238) ([Mecharyry](https://github.com/Mecharyry))

## [v1.2.0-beta.0](https://github.com/auth0/auth0-flutter/tree/v1.2.0-beta.0) (2023-04-14)

[Full Changelog](https://github.com/auth0/auth0-flutter/compare/v1.1.0...v1.2.0-beta.0)

This release adds support for the web platform.

**Added**

- [SDK-4110] Support options to `getTokenSilently` [\#232](https://github.com/auth0/auth0-flutter/pull/232) ([stevehobbsdev](https://github.com/stevehobbsdev))
- [SDK-4046] WebException wrapper [\#227](https://github.com/auth0/auth0-flutter/pull/227) ([stevehobbsdev](https://github.com/stevehobbsdev))
- [SDK-4009] Add support for custom parameters [\#226](https://github.com/auth0/auth0-flutter/pull/226) ([stevehobbsdev](https://github.com/stevehobbsdev))
- [SDK-4002] Add support for loginWithPopup [\#224](https://github.com/auth0/auth0-flutter/pull/224) ([stevehobbsdev](https://github.com/stevehobbsdev))
- [SDK-4001] Logout for web platform [\#223](https://github.com/auth0/auth0-flutter/pull/223) ([stevehobbsdev](https://github.com/stevehobbsdev))
- Support additional properties for SDK client [\#211](https://github.com/auth0/auth0-flutter/pull/211) ([stevehobbsdev](https://github.com/stevehobbsdev))
- Add credentials() and hasValidCredentials() [SDK-3997] [\#207](https://github.com/auth0/auth0-flutter/pull/207) ([Widcket](https://github.com/Widcket))
- [SDK-3984] Support login on web platform [\#203](https://github.com/auth0/auth0-flutter/pull/203) ([stevehobbsdev](https://github.com/stevehobbsdev))
- Add web platform boilerplate [SDK-3983] [\#197](https://github.com/auth0/auth0-flutter/pull/197) ([Widcket](https://github.com/Widcket))

## [v1.1.0](https://github.com/auth0/auth0-flutter/tree/v1.1.0) (2023-02-23)

[Full Changelog](https://github.com/auth0/auth0-flutter/compare/v1.0.2...v1.1.0)

**Added**

- Added support for `loginWithOtp` [\#172](https://github.com/auth0/auth0-flutter/pull/172) ([wferem1](https://github.com/wferem1))
- Added support for SafariViewController [\#198](https://github.com/auth0/auth0-flutter/pull/198) ([stevehobbsdev](https://github.com/stevehobbsdev))

**Fixed**

- Upgrade Flutter used for build, and fix linter warnings [\#199](https://github.com/auth0/auth0-flutter/pull/199) ([stevehobbsdev](https://github.com/stevehobbsdev))
- Fix README links [\#184](https://github.com/auth0/auth0-flutter/pull/184) ([Widcket](https://github.com/Widcket))

## [1.0.1](https://github.com/auth0/auth0-flutter/tree/1.0.1) (2022-08-25)

This is the General Availability release of the **Auth0 Flutter SDK**! 🎉

This release marks the first stable release of the SDK and is fully supported for use in production environments.

## :warning: Breaking changes

There are a small number of breaking changes from `1.0.0-fa.0` in this release:

**Renamed properties**
The following properties were renamed to comply with [Dart's API guidelines](https://dart.dev/guides/language/effective-dart/style#do-capitalize-acronyms-and-abbreviations-longer-than-two-letters-like-words).

See #146

- `UserProfile.profileURL` to `UserProfile.profileUrl`
- `UserProfile.pictureURL` to `UserProfile.pictureUrl`
- `UserProfile.websiteURL` to `UserProfile.websiteUrl`
- `ApiException.isInvalidAuthorizeURL` to `ApiException.isInvalidAuthorizeUrl`
- `ApiException.isPKCENotAvailable` to `ApiException.isPkceNotAvailable`

**Scheme registration**

The `scheme` option of `webAuthentication().login` and `webAuthentication().logout()` was moved up a level to become an option of `webAuthentication()` instead.

Before:

```dart
auth0.webAuthentication().login(scheme: 'custom-scheme');
auth0.webAuthentication().logout(scheme: 'custom-scheme');
```

After:

```dart
auth0.webAuthentication(scheme: 'custom-scheme').login();
auth0.webAuthentication(scheme: 'custom-scheme').logout();
```

See #150

**Renamed `LocalAuthenticationOptions`**

`LocalAuthenticationOptions` was renamed to `LocalAuthentication` to fix up some confusion about how the class was to be used.

See #152 for details.

## [1.0.0-fa.0](https://github.com/auth0/auth0-flutter/tree/1.0.0-fa.0) (2022-07-21)

This is a [First Availability](https://auth0.com/docs/troubleshoot/product-lifecycle/product-release-stages#first-availability) release of the **Auth0 Flutter SDK**! 🎉

This release includes the addition of a Credentials Manager: a mechanism to manage the tokens returned from Auth0, including the ability to automatically renew the access token when expired (web authentication only). [Read more about the credentials manager](https://github.com/auth0/auth0-flutter/tree/main/auth0_flutter#credentials-manager) in the `auth0_flutter` package readme.

## [1.0.0-beta.1](https://github.com/auth0/auth0-flutter/tree/1.0.0-beta.1) (2022-07-08)

This is the first public beta release of the **Auth0 Flutter SDK**! 🎉

> ⚠️ This release is not yet suitable for use in production

The Auth0 Flutter SDK is a new SDK designed to make it quick and easy to integrate Auth0 into Flutter applications. Today, the SDK offers the following features:

- Support for iOS and Android
- Integration with [Auth0 Universal Login](https://auth0.com/docs/authenticate/login/auth0-universal-login)
- Integration with the [Auth0 Authentication API](https://auth0.com/docs/api/authentication) for:
  - username and password login
  - signup
  - refreshing access tokens
  - password reset
  - fetching user profile

Check out [the Readme](https://github.com/auth0/auth0-flutter/blob/main/auth0_flutter/README.md) for a more detailed run through of the capabilities and API.

## [1.0.0-beta.0](https://github.com/auth0/auth0-flutter/tree/1.0.0-beta.0) (2022-05-05)

**Added**

- Web Auth login
- Web Auth logout
- Authenticaiton API login
- Authentication API signup
- Authentication API user profile
- Authentication API renew credentials
- Authentication API reset password
