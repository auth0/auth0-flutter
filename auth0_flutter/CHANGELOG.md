# Change Log

## [v1.2.0](https://github.com/auth0/auth0-flutter/tree/v1.2.0) (2023-05-31)
[Full Changelog](https://github.com/auth0/auth0-flutter/compare/v1.1.0...v1.2.0)

This release adds official support for the Web platform! 🎉 Please checkout [the readme](https://github.com/auth0/auth0-flutter/tree/main/auth0_flutter#readme) for full usage instructions for all supported platforms.

Other changes in this release:

**Added**
- Add support for requesting MFA challenges [SDK-4052] [\#251](https://github.com/auth0/auth0-flutter/pull/251) ([Widcket](https://github.com/Widcket))

**Fixed**
- Use Locale.US for Android [\#238](https://github.com/auth0/auth0-flutter/pull/238) ([Mecharyry](https://github.com/Mecharyry))

## [v1.2.0-beta.1](https://github.com/auth0/auth0-flutter/tree/v1.2.0-beta.1) (2023-05-24)

[Full Changelog](https://github.com/auth0/auth0-flutter/compare/v1.2.0-beta.0...v1.2.0-beta.1)

**Changed**

- Document how to load the SPA SDK in index.html [\#254](https://github.com/auth0/auth0-flutter/pull/254) ([Widcket](https://github.com/Widcket))
- Document how to pass the port `3000` when running a web app [\#249](https://github.com/auth0/auth0-flutter/pull/249) ([Widcket](https://github.com/Widcket))

**Fixed**

- fix: inline AuthParamsExtension.prepare usage and remove [SDK-4222] [\#260](https://github.com/auth0/auth0-flutter/pull/260) ([stevehobbsdev](https://github.com/stevehobbsdev))
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

- Support SFSafariViewController [\#198](https://github.com/auth0/auth0-flutter/pull/198) ([stevehobbsdev](https://github.com/stevehobbsdev))

**Fixed**

- Fix Apple login connection crash in Android [\#195](https://github.com/auth0/auth0-flutter/pull/195) ([poovamraj](https://github.com/poovamraj))

## [v1.0.2](https://github.com/auth0/auth0-flutter/tree/v1.0.2) (2022-11-03)

[Full Changelog](https://github.com/auth0/auth0-flutter/compare/v1.0.1...v1.0.2)

**Changed**

- af: Replace usages of `getOrDefault()` [\#179](https://github.com/auth0/auth0-flutter/pull/179) ([Widcket](https://github.com/Widcket))
- af: Update Podspec [\#180](https://github.com/auth0/auth0-flutter/pull/180) ([Widcket](https://github.com/Widcket))

**Security**

- [Snyk] Security upgrade slather from 2.7.2 to 2.7.2 [\#176](https://github.com/auth0/auth0-flutter/pull/176) ([crew-security](https://github.com/crew-security))

## [1.0.1](https://github.com/auth0/auth0-flutter/tree/v1.0.1) (2022-09-14)

[Full changelog](https://github.com/auth0/auth0-flutter/compare/v1.0.0...v1.0.1)

**Fixed**

- Fix timezone issue in Android Credentials Manager handler #162 ([widcket](https://github.com/widcket))

## [1.0.0](https://github.com/auth0/auth0-flutter/tree/v1.0.0) (2022-08-25)

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

## [1.0.0-fa.0](https://github.com/auth0/auth0-flutter/tree/1.0.0-fa.0) (2022-07-22)

This is a [First Availability](https://auth0.com/docs/troubleshoot/product-lifecycle/product-release-stages#first-availability) release of the **Auth0 Flutter SDK**! 🎉

This release includes the addition of a Credentials Manager: a mechanism to manage the tokens returned from Auth0, including the ability to automatically renew the access token when expired (web authentication only). [Read more about the credentials manager](https://github.com/auth0/auth0-flutter/tree/main/auth0_flutter#credentials-manager) in the readme.

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
