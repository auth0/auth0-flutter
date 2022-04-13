# auth0_flutter (Early Access)

[![CircleCI](https://img.shields.io/circleci/project/github/auth0/auth0-flutter.svg?style=flat-square)](https://circleci.com/gh/auth0/auth0-flutter/tree/main)

Auth0 SDK for Android / iOS Flutter applications.

---

## Table of Contents

- [**Documentation**](#documentation)
- [**Requirements**](#requirements)
- [**Installation**](#installation)
- [**Getting Started**](#getting-started)
  + [Configuration](#configuration)
  + [Web Auth Configuration](#web-auth-configuration)
  + [Web Auth Login](#web-auth-login)
  + [Web Auth Logout](#web-auth-logout)
  + [SSO Alert Box (iOS)](#sso-alert-box-ios)
- [**Next Steps**](#next-steps)
  + [Common Tasks](#common-tasks)
  + [Web Auth](#web-auth)
  + [API](#api)
- [**Advanced Features**](#advanced-features)
  + [Organizations](#organizations)
  + [Bot Detection](#bot-detection)
- [**Issue Reporting**](#issue-reporting)
- [**What is Auth0?**](#what-is-auth0)
- [**License**](#license)

## Documentation

_TBD_

## Requirements

| Flutter    | Android         |iOS                |
|:-----------|:----------------|:------------------|
| SDK 2.10+  | Android API 21+ | iOS 12+           |
| Dart 2.16+ | Java 8+         | Swift 5.3+        |
|            |                 | Xcode 12.x / 13.x |

## Installation

_TBD_

## Getting Started

### Configuration

auth0_flutter needs the **Client ID** and **Domain** of the Auth0 application to communicate with Auth0. You can find these details on the settings page of your [Auth0 application](https://manage.auth0.com/#/applications/). If you are using a [Custom Domain](https://auth0.com/docs/brand-and-customize/custom-domains), use the value of your Custom Domain instead of the value from the settings page.

> ⚠️ Make sure that the [application type](https://auth0.com/docs/configure/applications) of the Auth0 application is **Native**. If you don’t have a Native Auth0 application, [create one](https://auth0.com/docs/get-started/create-apps/native-apps) before continuing.

_[snippet]_

### Web Auth Configuration

#### Configure callback and logout URLs

The callback and logout URLs are the URLs that Auth0 invokes to redirect back to your application. Auth0 invokes the callback URL after authenticating the user, and the logout URL after removing the session cookie.

Since callback and logout URLs can be manipulated, you will need to add your URLs to the **Allowed Callback URLs** and **Allowed Logout URLs** fields in the settings page of your Auth0 application. This will enable Auth0 to recognize these URLs as valid. If the callback and logout URLs are not set, users will be unable to log in and out of the application and will get an error.

Go to the settings page of your [Auth0 application](https://manage.auth0.com/#/applications/) and add the corresponding URLs to **Allowed Callback URLs** and **Allowed Logout URLs**, according to the platforms used by your application. If you are using a [Custom Domain](https://auth0.com/docs/brand-and-customize/custom-domains), replace `YOUR_AUTH0_DOMAIN` with the value of your Custom Domain instead of the value from the settings page.

##### Android

```text
https://YOUR_AUTH0_DOMAIN/android/YOUR_APP_PACKAGE_NAME/callback
```

E.g. if your Auth0 Domain was `company.us.auth0.com` and your Android app package name was `com.company.myapp`, then this value would be:

```text
https://company.us.auth0.com/android/com.company.myapp/callback
```

##### iOS

```text
YOUR_BUNDLE_IDENTIFIER://YOUR_AUTH0_DOMAIN/ios/YOUR_BUNDLE_IDENTIFIER/callback
```

E.g. if your iOS bundle identifier was `com.company.myapp` and your Auth0 Domain was `company.us.auth0.com`, then this value would be:

```text
com.company.myapp://company.us.auth0.com/ios/com.company.myapp/callback
```

#### Android configuration: manifest placeholders

_TBD_

#### iOS configuration: custom URL scheme

Open the `ios/Runner/Info.plist` file and add the following snippet inside the top-level `<dict>` tag. This registers your iOS Bundle Identifer as a custom scheme, so the callback URL can reach your application.

```xml
<!-- ios/Runner/Info.plist -->

<!-- <dict> -->
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>None</string>
        <key>CFBundleURLName</key>
        <string>auth0</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
        </array>
    </dict>
</array>
<!-- </dict> -->
```

> 💡 If you're opening the `Info.plist` file in Xcode and it is not being shown in this format, you can **Right Click** on `Info.plist` in the Xcode [project navigator](https://developer.apple.com/library/archive/documentation/ToolsLanguages/Conceptual/Xcode_Overview/NavigatingYourWorkspace.html) and then select **Open As > Source Code**.

### Web Auth Login

_TBD_

### Web Auth Logout

_TBD_

### SSO Alert Box (iOS)

![ios-sso-alert](assets/ios-sso-alert.png)

Check the [FAQ](FAQ.md) for more information about the alert box that pops up **by default** when using Web Auth on iOS.

> 💡 See also [this blog post](https://developer.okta.com/blog/2022/01/13/mobile-sso) for a detailed overview of Single Sign-On (SSO) on iOS.

[Go up ⤴](#table-of-contents)

## Next Steps

### Common Tasks

_TBD_

### Web Auth

**See all the available features in the API documentation ↗** _[link to API documentation]_

- [Web Auth signup](#web-auth-signup)
- [Web Auth configuration](#web-auth-configuration)
- [ID Token validation](#id-token-validation)
- [Web Auth errors](#web-auth-errors)

#### Web Auth signup

You can make users land directly on the Signup page instead of the Login page by specifying the `'screen_hint': 'signup'` parameter. Note that this can be combined with `'prompt': 'login'`, which indicates whether you want to always show the authentication page or you want to skip if there's an existing session.

| Parameters                                     | No existing session   | Existing session              |
|:-----------------------------------------------|:----------------------|:------------------------------|
| No extra parameters                            | Shows the login page  | Redirects to the callback url |
| `'screen_hint': 'signup'`                      | Shows the signup page | Redirects to the callback url |
| `'prompt': 'login'`                            | Shows the login page  | Shows the login page          |
| `'prompt': 'login', 'screen_hint': 'signup'`   | Shows the signup page | Shows the signup page         |

_[snippet]_

> ⚠️ The `screen_hint` parameter will work with the **New Universal Login Experience** without any further configuration. If you are using the **Classic Universal Login Experience**, you need to customize the [login template](https://manage.auth0.com/#/login_page) to look for this parameter and set the `initialScreen` [option](https://github.com/auth0/lock#database-options) of the `Auth0Lock` constructor.

#### Web Auth configuration

The following are some of the available Web Auth configuration options. Check the API documentation _[link to API documentation]_ for the full list.

##### Add an audience value

Specify an [audience](https://auth0.com/docs/secure/tokens/access-tokens/get-access-tokens#control-access-token-audience) to obtain an Access Token that can be used to make authenticated requests to a backend. The audience value is the **API Identifier** of your [Auth0 API](https://auth0.com/docs/get-started/apis), e.g. `https://example.com/api`.

_[snippet]_

##### Add scope values

Specify [scopes](https://auth0.com/docs/get-started/apis/scopes) to request permission to access protected resources, like the user profile. The default scope values are `openid`, `profile`, `email`, and `offline_access`. Regardless of the values specified, `openid` is always included.

_[snippet]_

#### ID Token validation

auth0_flutter automatically [validates](https://auth0.com/docs/secure/tokens/id-tokens/validate-id-tokens) the ID Token obtained from Web Auth login, following the [OpenID Connect specification](https://openid.net/specs/openid-connect-core-1_0.html). This ensures the contents of the ID Token have not been tampered with and can be safely used.

##### Custom Domains

Users of Auth0 Private Cloud with Custom Domains still on the [legacy behavior](https://auth0.com/docs/deploy/private-cloud/private-cloud-migrations/migrate-private-cloud-custom-domains) need to specify a custom issuer to match the Auth0 Domain when performing Web Auth login. Otherwise, the ID Token validation will fail.

_[snippet]_

#### Web Auth errors

_TBD_

### API

**See all the available features in the API documentation ↗** _[link to API documentation]_

- [Login with database connection](#login-with-database-connection)
- [Sign up with database connection](#sign-up-with-database-connection)
- [Retrieve user information](#retrieve-user-information)
- [Renew credentials](#renew-credentials)
- [API client configuration](#api-client-configuration)
- [API client errors](#api-client-errors)

The Authentication API exposes the AuthN/AuthZ functionality of Auth0, as well as the supported identity protocols like OpenID Connect, OAuth 2.0, and SAML.
We recommend using [Universal Login](https://auth0.com/docs/authenticate/login/auth0-universal-login), but if you prefer to build your own UI you can use our API endpoints to do so. However, some Auth flows (grant types) are disabled by default so you must enable them in the settings page of your [Auth0 application](https://manage.auth0.com/#/applications/), as explained in [Update Grant Types](https://auth0.com/docs/get-started/applications/update-grant-types).

For login or signup with username/password, the `Password` grant type needs to be enabled in your application. If you set the grants via the Management API you should activate both `http://auth0.com/oauth/grant-type/password-realm` and `Password`. Otherwise, the Auth0 Dashboard will take care of activating both when enabling `Password`.

> 💡 If your Auth0 account has the **Bot Detection** feature enabled, your requests might be flagged for verification. Check how to handle this scenario in the [Bot Detection](#bot-detection) section.

> ⚠️ The ID Tokens obtained from Web Auth login are automatically validated by auth0_flutter, ensuring their contents have not been tampered with. **This is not the case for the ID Tokens obtained from the Authentication API client.** You must [validate](https://auth0.com/docs/security/tokens/id-tokens/validate-id-tokens) any ID Tokens received from the Authentication API client before using the information they contain.

#### Login with database connection

_[snippet]_

> 💡 The default scope values are `openid`, `profile`, `email`, and `offline_access`. Regardless of the values specified, `openid` is always included.

#### Sign up with database connection

_[snippet]_

> 💡 You might want to log the user in after signup. See [Login with database connection](#login-with-database-connection) above for an example.

#### Retrieve user information

Fetch the latest user information from the `/userinfo` endpoint.

This method will yield a `UserProfile` instance. Check the API documentation _[link to API documentation]_ to learn more about its available properties.

_[snippet]_

#### Renew credentials

Use a [Refresh Token](https://auth0.com/docs/secure/tokens/refresh-tokens) to renew the user's credentials. It's recommended that you read and understand the Refresh Token process beforehand.

_[snippet]_

> 💡 To obtain a Refresh Token, make sure your Auth0 application has the **Refresh Token** [grant enabled](https://auth0.com/docs/get-started/applications/update-grant-types). If you are also specifying an audience value, make sure that the corresponding Auth0 API has the **Allow Offline Access** [setting enabled](https://auth0.com/docs/get-started/apis/api-settings#access-settings).

#### API client configuration

##### Add custom parameters

_TBD_

#### Authentication API client errors

_TBD_

[Go up ⤴](#table-of-contents)

## Advanced Features

### Organizations

[Organizations](https://auth0.com/docs/manage-users/organizations) is a set of features that provide better support for developers who build and maintain SaaS and Business-to-Business (B2B) applications. 

Using Organizations, you can:

- Represent teams, business customers, partner companies, or any logical grouping of users that should have different ways of accessing your applications, as organizations.
- Manage their membership in a variety of ways, including user invitation.
- Configure branded, federated login flows for each organization.
- Implement role-based access control, such that users can have different roles when authenticating in the context of different organizations.
- Build administration capabilities into your products, using Organizations APIs, so that those businesses can manage their own organizations.

> 💡 Organizations is currently only available to customers on our Enterprise and Startup subscription plans.

#### Log in to an organization

_[snippet]_

#### Accept user invitations

_TBD_

### Bot Detection

If you are performing database login/signup via the Authentication API and would like to use the [Bot Detection](https://auth0.com/docs/secure/attack-protection/bot-detection) feature, you need to handle the `isVerificationRequired` error. It indicates that the request was flagged as suspicious and an additional verification step is necessary to log the user in. That verification step is web-based, so you need to use Web Auth to complete it.

_[snippet]_

## Issue Reporting

For general support or usage questions, use the [Auth0 Community](https://community.auth0.com/c/sdks/5) forums or raise a [support ticket](https://support.auth0.com/). Only [raise an issue](https://github.com/auth0/auth0_flutter/issues) if you have found a bug or want to request a feature.

**Do not report security vulnerabilities on the public GitHub issue tracker.** The [Responsible Disclosure Program](https://auth0.com/responsible-disclosure-policy) details the procedure for disclosing security issues.

## What is Auth0?

Auth0 helps you to:

* Add authentication with [multiple sources](https://auth0.com/docs/authenticate/identity-providers), either social identity providers such as **Google, Facebook, Microsoft Account, LinkedIn, GitHub, Twitter, Box, Salesforce** (amongst others), or enterprise identity systems like **Windows Azure AD, Google Apps, Active Directory, ADFS, or any SAML Identity Provider**.
* Add authentication through more traditional **[username/password databases](https://auth0.com/docs/authenticate/database-connections/custom-db)**.
* Add support for **[linking different user accounts](https://auth0.com/docs/manage-users/user-accounts/user-account-linking)** with the same user.
* Support for generating signed [JSON Web Tokens](https://auth0.com/docs/secure/tokens/json-web-tokens) to call your APIs and **flow the user identity** securely.
* Analytics of how, when, and where users are logging in.
* Pull data from other sources and add it to the user profile through [JavaScript Actions](https://auth0.com/docs/customize/actions).

**Why Auth0?** Because you should save time, be happy, and focus on what really matters: building your product.

## License

This project is licensed under the MIT license. See the [LICENSE](LICENSE) file for more information.

---

[Go up ⤴](#table-of-contents)
