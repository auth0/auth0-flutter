![Auth0 Flutter SDK](https://cdn.auth0.com/website/sdks/banners/flutter-banner.png)

[![Package](https://img.shields.io/pub/v/auth0_flutter.svg)](https://pub.dartlang.org/packages/auth0_flutter)
[![Codecov](https://codecov.io/gh/auth0/auth0-flutter/branch/main/graph/badge.svg)](https://codecov.io/gh/auth0/auth0-flutter)
[![License](https://img.shields.io/github/license/auth0/auth0-flutter)](https://www.apache.org/licenses/LICENSE-2.0)
[![CircleCI](https://img.shields.io/circleci/project/github/auth0/auth0-flutter.svg)](https://circleci.com/gh/auth0/auth0-flutter/tree/main)

<div>
📚 <a href="#documentation">Documentation</a> - 🚀 <a href="#getting-started">Getting started</a> - 💻 <a href="#api-reference">API reference</a> - 💬 <a href="#feedback">Feedback</a>
</div>

## Documentation

- [Quickstart](https://auth0.com/docs/quickstart/native/flutter/interactive) - our interactive guide for quickly adding login, logout and user information to your app using Auth0
- [Sample app](https://github.com/auth0-samples/auth0-flutter-samples/tree/main/sample) - a full-fledged sample app integrated with Auth0
- [API documentation](https://pub.dev/documentation/auth0_flutter/latest/) - documentation auto-generated from the code comments that explains all the available features
- [Examples](https://github.com/auth0/auth0-flutter/blob/main/EXAMPLES.md) - examples that demonstrate the different ways in which this SDK can be used
- [FAQ](https://github.com/auth0/auth0-flutter/blob/main/FAQ.md) - frequently asked questions about the SDK
- [Docs Site](https://auth0.com/docs) - explore our Docs site and learn more about Auth0

## Getting Started

### Requirements

| Flutter    | Android         | iOS               |
| :--------- | :-------------- | :---------------- |
| SDK 3.0+   | Android API 21+ | iOS 12+           |
| Dart 2.17+ | Java 8+         | Swift 5.3+        |
|            |                 | Xcode 13.x / 14.x |

### Installation

Add auth0_flutter into your project:

```sh
flutter pub add auth0_flutter
```

### Configure Auth0

Create a **Native Application** in the [Auth0 Dashboard](https://manage.auth0.com).

> If you're using an existing application, verify you have configured the following settings in your Native Application:
>
> - Click on the "Settings" tab of your application's page
> - Ensure that "Application Type" is set to "Native"
> - Ensure that the "Token Endpoint Authentication Method" setting has a value of "None"
> - Scroll down and click on the "Show Advanced Settings" link
> - Under "Advanced Settings", click on the "OAuth" tab
> - Ensure that "JsonWebToken Signature Algorithm" is set to `RS256` and that "OIDC Conformant" is enabled

Next, configure the following URLs for your application under the "Application URIs" section of the "Settings" page, for both **Allowed Callback URLs** and **Allowed Logout URLs**:

- Android: `SCHEME://YOUR_DOMAIN/android/YOUR_PACKAGE_NAME/callback`
- iOS: `YOUR_BUNDLE_ID://YOUR_DOMAIN/ios/YOUR_BUNDLE_ID/callback`

For example, if your Auth0 domain was `company.us.auth0.com` and your package name (Android) or bundle ID (iOS) was `com.company.myapp`, then these values would be:

```text
Android:
https://company.us.auth0.com/android/com.company.myapp/callback

iOS:
com.company.myapp://company.us.auth0.com/ios/com.company.myapp/callback
```

Take note of the **Client ID** and **Domain** values under the "Basic Information" section. You'll need these values in the next step.

### Configure the SDK

Instantiate the `Auth0` class, providing your domain and Client ID values from the previous step:

```dart
final auth0 = Auth0('YOUR_AUTH0_DOMAIN', 'YOUR_AUTH0_CLIENT_ID');
```

#### Configure manifest placeholders (Android only)

Open the `android/build.gradle` file and add the following manifest placeholders inside `android > defaultConfig`.

```groovy
// android/build.gradle

android {
    // ...

    defaultConfig {
        // ...
        // Add the following line
        manifestPlaceholders = [auth0Domain: "YOUR_AUTH0_DOMAIN", auth0Scheme: "https"]
    }

    // ...
}
```

For example, if your Auth0 domain was `company.us.auth0.com`, then the manifest placeholders line would be:

```groovy
manifestPlaceholders = [auth0Domain: "company.us.auth0.com", auth0Scheme: "https"]
```

> 💡 If your Android app is using [product flavors](https://developer.android.com/studio/build/build-variants#product-flavors), you might need to specify different manifest placeholders for each flavor.

<details>
  <summary>Skipping the Android Web Auth configuration</summary>

If you don't plan to use Web Auth, you will notice that the compiler will still prompt you to provide the `manifestPlaceholders` values, since the `RedirectActivity` included in this library will require them, and the Gradle tasks won't be able to run without them.

Re-declare the activity manually using `tools:node="remove"` in the `android/src/main/AndroidManifest.xml` file to make the [manifest merger](https://developer.android.com/studio/build/manage-manifests#merge-manifests) remove it from the final manifest file. Additionally, one more unused activity can be removed from the final APK by using the same process. A complete snippet to achieve this is:

```xml
<!-- android/src/main/AndroidManifest.xml -->

<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools"
    package="com.company.myapp">
    <application android:theme="@style/AppTheme">
        <!-- ... -->

        <activity
            android:name="com.auth0.android.provider.AuthenticationActivity"
            tools:node="remove"/>
        <!-- Optional: Remove RedirectActivity -->
        <activity
            android:name="com.auth0.android.provider.RedirectActivity"
            tools:node="remove"/>

        <!-- ... -->
    </application>
</manifest>
```

</details>

#### Custom URL scheme configuration (iOS only)

Open the `ios/Runner/Info.plist` file and add the following snippet inside the top-level `<dict>` tag. This registers your iOS bundle identifier as a custom URL scheme, so the callback and logout URLs can reach your app.

```xml
<!-- ios/Runner/Info.plist -->

<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
<!-- ... -->

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

<!-- ... -->
</dict>
</plist>
```

> 💡 If you're opening the `Info.plist` file in Xcode and it is not being shown in this format, you can **Right Click** on `Info.plist` in the Xcode [project navigator](https://developer.apple.com/library/archive/documentation/ToolsLanguages/Conceptual/Xcode_Overview/NavigatingYourWorkspace.html) and then select **Open As > Source Code**.

### Logging in

Import `auth0_flutter` in the file where you want to present the login page.

```dart
import 'package:auth0_flutter/auth0_flutter.dart';
```

Then, present the [Universal Login](https://auth0.com/docs/authenticate/login/auth0-universal-login) page in the `onPressed` callback of your **Login** button.

```dart
final credentials = await auth0.webAuthentication().login();
// Access token -> credentials.accessToken
// User profile -> credentials.user
```

auth0_flutter will automatically store the user's credentials using the built-in [Credentials Manager](#credentials-manager) instance. You can access this instance through the `credentialsManager` property.

```dart
final credentials = await auth0.credentialsManager.credentials();
```

For other comprehensive examples, see the [EXAMPLES.md](EXAMPLES.md) document.

### SSO Alert Box (iOS)

![ios-sso-alert](../assets/ios-sso-alert.png)

Check the [FAQ](FAQ.md) for more information about the alert box that pops up **by default** when using Web Auth on iOS.

> 💡 See also [this blog post](https://developer.okta.com/blog/2022/01/13/mobile-sso) for a detailed overview of Single Sign-On (SSO) on iOS.

### Common Tasks

- [Check for stored credentials](EXAMPLES.md#check-for-stored-credentials) - check if the user is already logged in when your app starts up.
- [Retrieve stored credentials](EXAMPLES.md#retrieve-stored-credentials) - fetch the user's credentials from the storage, automatically renewing them if they have expired.
- [Retrieve user information](EXAMPLES.md#retrieve-user-information) - fetch the latest user information from the `/userinfo` endpoint.

## API reference

### Web authentication

- [login](https://pub.dev/documentation/auth0_flutter/latest/auth0_flutter/WebAuthentication/login.html)
- [logout](https://pub.dev/documentation/auth0_flutter/latest/auth0_flutter/WebAuthentication/logout.html)

### API

- [login](https://pub.dev/documentation/auth0_flutter/latest/auth0_flutter/AuthenticationApi/login.html)
- [renewCredentials](https://pub.dev/documentation/auth0_flutter/latest/auth0_flutter/AuthenticationApi/renewCredentials.html)
- [resetPassword](https://pub.dev/documentation/auth0_flutter/latest/auth0_flutter/AuthenticationApi/resetPassword.html)
- [signup](https://pub.dev/documentation/auth0_flutter/latest/auth0_flutter/AuthenticationApi/signup.html)
- [userProfile](https://pub.dev/documentation/auth0_flutter/latest/auth0_flutter/AuthenticationApi/userProfile.html)

### Credentials Manager

- [credentials](https://pub.dev/documentation/auth0_flutter/latest/auth0_flutter/DefaultCredentialsManager/credentials.html)
- [hasValidCredentials](https://pub.dev/documentation/auth0_flutter/latest/auth0_flutter/DefaultCredentialsManager/hasValidCredentials.html)
- [storeCredentials](https://pub.dev/documentation/auth0_flutter/latest/auth0_flutter/DefaultCredentialsManager/storeCredentials.html)
- [clearCredentials](https://pub.dev/documentation/auth0_flutter/latest/auth0_flutter/DefaultCredentialsManager/clearCredentials.html)

## Feedback

### Contributing

We appreciate feedback and contribution to this repo! Before you get started, please see the following:

- [Auth0's general contribution guidelines](https://github.com/auth0/open-source-template/blob/master/GENERAL-CONTRIBUTING.md)
- [Auth0's code of conduct guidelines](https://github.com/auth0/open-source-template/blob/master/CODE-OF-CONDUCT.md)

### Raise an issue

To provide feedback or report a bug, please [raise an issue on our issue tracker](https://github.com/auth0/auth0-flutter/issues).

### Vulnerability Reporting

Please do not report security vulnerabilities on the public GitHub issue tracker. The [Responsible Disclosure Program](https://auth0.com/whitehat) details the procedure for disclosing security issues.

## What is Auth0?

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://cdn.auth0.com/website/sdks/logos/auth0_dark_mode.png" width="150">
    <source media="(prefers-color-scheme: light)" srcset="https://cdn.auth0.com/website/sdks/logos/auth0_light_mode.png" width="150">
    <img alt="Auth0 Logo" src="https://cdn.auth0.com/website/sdks/logos/auth0_light_mode.png" width="150">
  </picture>
</p>
<p align="center">
  Auth0 is an easy to implement, adaptable authentication and authorization platform. To learn more checkout <a href="https://auth0.com/why-auth0">Why Auth0?</a>
</p>
<p align="center">
  This project is licensed under the Apache 2.0 license. See the <a href="https://github.com/auth0/auth0-flutter/blob/main/LICENSE"> LICENSE</a> file for more info.
</p>
