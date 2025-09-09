![Auth0 Flutter SDK](https://cdn.auth0.com/website/sdks/banners/flutter-banner.png)

[![Package](https://img.shields.io/pub/v/auth0_flutter.svg)](https://pub.dartlang.org/packages/auth0_flutter)
[![Codecov](https://codecov.io/gh/auth0/auth0-flutter/branch/main/graph/badge.svg)](https://codecov.io/gh/auth0/auth0-flutter)
[![License](https://img.shields.io/github/license/auth0/auth0-flutter)](https://www.apache.org/licenses/LICENSE-2.0)
![Build Status](https://img.shields.io/github/actions/workflow/status/auth0/auth0-flutter/main.yml?style=flat)

<div>
📚 <a href="#documentation">Documentation</a> • 🚀 <a href="#getting-started">Getting started</a> • 🌐 <a href="#api-reference">API reference</a> • 💬 <a href="#feedback">Feedback</a>
</div>

## Documentation

- Quickstarts: [Native](https://auth0.com/docs/quickstart/native/flutter/interactive) / [Web](https://auth0.com/docs/quickstart/spa/flutter/interactive) - our interactive guide for quickly adding login, logout and user information to your app using Auth0
- [Sample app](https://github.com/auth0-samples/auth0-flutter-samples/tree/main/sample) - a full-fledged sample app integrated with Auth0
- [API documentation](https://pub.dev/documentation/auth0_flutter/latest/) - documentation auto-generated from the code comments that explains all the available features
- [Examples](https://github.com/auth0/auth0-flutter/blob/main/auth0_flutter/EXAMPLES.md) - examples that demonstrate the different ways in which this SDK can be used
- [FAQ](https://github.com/auth0/auth0-flutter/blob/main/auth0_flutter/FAQ.md) - frequently asked questions about the SDK
- [Docs Site](https://auth0.com/docs) - explore our Docs site and learn more about Auth0

## Getting Started

### Requirements

| Flutter    | Android         | iOS               | macOS             |
| :--------- | :-------------- | :---------------- | :---------------- |
| SDK 3.0+   | Android API 21+ | iOS 14+           | macOS 11+         |
| Dart 2.17+ | Java 8+         | Swift 5.9+        | Swift 5.9+        |
|            |                 | Xcode 15.x / 16.x | Xcode 15.x / 16.x |

### Installation

Add auth0_flutter into your project:

```sh
flutter pub add auth0_flutter
```

### Configure Auth0

#### 📱 Mobile/macOS

Head to the [Auth0 Dashboard](https://manage.auth0.com/#/applications/) and create a new **Native** application.

<details>
  <summary>Using an existing <strong>Native</strong> application?</summary>

Select the **Settings** tab of your [application's page](https://manage.auth0.com/#/applications/) and ensure that **Application Type** is set to `Native`. Avoid using other application types, as they have different configurations and may cause errors.

Scroll down and select the **Show Advanced Settings** link. Under **Advanced Settings**, select the **OAuth** tab and verify the following:

- Ensure that **JsonWebToken Signature Algorithm** is set to `RS256`
- Ensure that **OIDC Conformant** is enabled

Finally, if you made any changes don't forget to scroll to the end and press the **Save Changes** button.

</details>

##### Configure the callback and logout URLs

The callback and logout URLs are the URLs that Auth0 invokes to redirect back to your app. Auth0 invokes the callback URL after authenticating the user, and the logout URL after removing the session cookie.

> 💡 On iOS 17.4+ and macOS 14.4+ it is possible to use Universal Links as callback and logout URLs. When enabled, auth0_flutter will fall back to using a custom URL scheme on older iOS / macOS versions.
>
> Whenever possible, Auth0 recommends using Universal Links as a secure way to link directly to content within your iOS app. Custom URL schemes can be subject to [client impersonation attacks](https://datatracker.ietf.org/doc/html/rfc8252#section-8.6).
>
> **This feature requires Xcode 15.3+ and a paid Apple Developer account**.

Under the **Application URIs** section of the **Settings** page, configure the following URLs for your application for both **Allowed Callback URLs** and **Allowed Logout URLs**:

- Android: `SCHEME://YOUR_DOMAIN/android/YOUR_PACKAGE_NAME/callback`
- iOS: `https://YOUR_DOMAIN/ios/YOUR_BUNDLE_ID/callback,YOUR_BUNDLE_ID://YOUR_DOMAIN/ios/YOUR_BUNDLE_ID/callback`
- macOS: `https://YOUR_DOMAIN/macos/YOUR_BUNDLE_ID/callback,YOUR_BUNDLE_ID://YOUR_DOMAIN/macos/YOUR_BUNDLE_ID/callback`

<details>
  <summary>Example</summary>

If your Auth0 domain was `company.us.auth0.com` and your package name (Android) or bundle ID (iOS/macOS) was `com.company.myapp`, then these values would be:

- Android: `https://company.us.auth0.com/android/com.company.myapp/callback`
- iOS: `https://company.us.auth0.com/ios/com.company.myapp/callback,com.company.myapp://company.us.auth0.com/ios/com.company.myapp/callback`
- macOS: `https://company.us.auth0.com/macos/com.company.myapp/callback,com.company.myapp://company.us.auth0.com/macos/com.company.myapp/callback`

</details>

Take note of the **client ID** and **domain** values under the **Basic Information** section. You'll need these values in the next step.

#### 🌐 Web

Head to the [Auth0 Dashboard](https://manage.auth0.com/#/applications/) and create a new **Single Page** application.

<details>
  <summary>Using an existing <strong>Single Page</strong> application?</summary>

Select the **Settings** tab of your [application's page](https://manage.auth0.com/#/applications/) and ensure that **Application Type** is set to `Single Page Application`.

Then, scroll down and select the **Show Advanced Settings** link. Under **Advanced Settings**, select the **OAuth** tab and verify the following:

- Ensure that **JsonWebToken Signature Algorithm** is set to `RS256`
- Ensure that **OIDC Conformant** is enabled

If you made any changes don't forget to scroll to the end and press the **Save Changes** button.

Finally, head over to the **Credentials** tab and ensure that **Authentication Methods** is set to `None`.

</details>

Next, configure the following URLs for your application under the **Application URIs** section of the **Settings** page:

- Allowed Callback URLs: `http://localhost:3000`
- Allowed Logout URLs: `http://localhost:3000`
- Allowed Web Origins: `http://localhost:3000`

> 💡 These URLs should reflect the origins that your app is running on. **Allowed Callback URLs** may also include a path, depending on where you're calling auth0_flutter's `onLoad()` method –[see below](#-web-2).

> 💡 Make sure to use port `3000` when running your app: `flutter run -d chrome --web-port 3000`.

> 💡 Compile with WASM by running the app: `flutter run -d chrome --web-port 3000 --wasm`.

Take note of the **client ID** and **domain** values under the **Basic Information** section. You'll need these values in the next step.

### Configure the SDK

#### 📱 Mobile/macOS

Start by importing `auth0_flutter/auth0_flutter.dart`.

```dart
import 'package:auth0_flutter/auth0_flutter.dart';
```

Then, instantiate the `Auth0` class, providing your domain and client ID values from the previous step:

```dart
final auth0 = Auth0('YOUR_AUTH0_DOMAIN', 'YOUR_AUTH0_CLIENT_ID');
```

##### Android: Configure manifest placeholders

Open the `android/app/build.gradle` file and add the following manifest placeholders inside **android > defaultConfig**.

```groovy
// android/build.gradle

android {
    // ...
    defaultConfig {
        // ...
        // Add the following line
        manifestPlaceholders += [auth0Domain: "YOUR_AUTH0_DOMAIN", auth0Scheme: "https"]
    }
    // ...
}
```

<details>
  <summary>Example</summary>

If your Auth0 domain was `company.us.auth0.com`, then the manifest placeholders line would be:

```groovy
manifestPlaceholders = [auth0Domain: "company.us.auth0.com", auth0Scheme: "https"]
```

</details>

<details>
  <summary>Not using web authentication?</summary>

If you don't plan to use web authentication, you will notice that the compiler will still prompt you to provide the `manifestPlaceholders` values, since the `RedirectActivity` included in this library will require them, and the Gradle tasks won't be able to run without them.

Re-declare the activity manually using `tools:node="remove"` in the `android/src/main/AndroidManifest.xml` file to make the [manifest merger](https://developer.android.com/studio/build/manage-manifests/#merge-manifests) remove it from the final manifest file. Additionally, one more unused activity can be removed from the final APK by using the same process. A complete snippet to achieve this is:

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

> 💡 `https` schemes require enabling [Android App
> Links](https://auth0.com/docs/get-started/applications/enable-android-app-links-support). You can
> read more about setting this value in the [Auth0.Android SDK
> README](https://github.com/auth0/Auth0.Android#a-note-about-app-deep-linking).

> Whenever possible, Auth0 recommends using [Android App Links](https://auth0.com/docs/applications/enable-android-app-links) as a secure way to link directly to content within your app. Custom URL schemes can be subject to [client impersonation attacks](https://datatracker.ietf.org/doc/html/rfc8252#section-8.6).

> 💡 If your Android app is using [product flavors](https://developer.android.com/studio/build/build-variants#product-flavors), you might need to specify different manifest placeholders for each flavor.

##### iOS/macOS: Configure the associated domain

> ⚠️ This step requires a paid Apple Developer account. It is needed to use Universal Links as callback and logout URLs.
> Skip this step to use a custom URL scheme instead.

Select the **Settings** tab of your [application's page](https://manage.auth0.com/#/applications/), scroll to the end, and open **Advanced Settings > Device Settings**. In the **iOS** section, set **Team ID** to your [Apple Team ID](https://developer.apple.com/help/account/manage-your-team/locate-your-team-id/), and **App ID** to your app's bundle identifier.

![Screenshot of the iOS section inside the Settings page of the Auth0 application](https://github.com/auth0/Auth0.swift/assets/5055789/7eb5f6a2-7cc7-4c70-acf3-633fd72dc506)

This will add your app to your Auth0 tenant's `apple-app-site-association` file.

Next, open your app in Xcode by running `open ios/Runner.xcworkspace` (or `open macos/Runner.xcworkspace` for macOS). Go to the **Signing and Capabilities** [tab](https://developer.apple.com/documentation/xcode/adding-capabilities-to-your-app#Add-a-capability) of the **Runner** target settings, and press the **+ Capability** button. Then select **Associated Domains**.

![Screenshot of the capabilities library inside Xcode](https://github.com/auth0/Auth0.swift/assets/5055789/3f7b0a70-c36c-46bf-9441-29f98724204a)

Under **Associated Domains**, add the following [entry](https://developer.apple.com/documentation/xcode/configuring-an-associated-domain#Define-a-service-and-its-associated-domain):

```text
webcredentials:YOUR_AUTH0_DOMAIN
```

<details>
  <summary>Example</summary>

If your Auth0 Domain were `example.us.auth0.com`, then this value would be:

```text
webcredentials:example.us.auth0.com
```
</details>

If you have a [custom domain](https://auth0.com/docs/customize/custom-domains), replace `YOUR_AUTH0_DOMAIN` with your custom domain.

> ⚠️ For the associated domain to work, your app must be signed with your team certificate **even when building for the iOS simulator**. Make sure you are using the Apple Team whose Team ID is configured in the **Settings** page of your application.

#### 🌐 Web

Start by importing `auth0_flutter/auth0_flutter_web.dart`.

```dart
import 'package:auth0_flutter/auth0_flutter_web.dart';
```

Then, instantiate the `Auth0Web` class, providing your domain and client ID values from the previous step:

```dart
final auth0Web = Auth0Web('YOUR_AUTH0_DOMAIN', 'YOUR_AUTH0_CLIENT_ID');
```

> ⚠️ You should have only one instance of this class.

Finally, in your `index.html` add the following `<script>` tag:

```html
<script src="https://cdn.auth0.com/js/auth0-spa-js/2.0/auth0-spa-js.production.js" defer></script>
```

### Logging in

#### 📱 Mobile/macOS

Present the [Universal Login](https://auth0.com/docs/authenticate/login/auth0-universal-login) page in the `onPressed` callback of your **Login** button.

```dart
// Use a Universal Link callback URL on iOS 17.4+ / macOS 14.4+
// useHTTPS is ignored on Android
final credentials = await auth0.webAuthentication().login(useHTTPS: true);

// Access token -> credentials.accessToken
// User profile -> credentials.user
```

auth0_flutter automatically stores the user's credentials using the built-in [Credentials Manager](#credentials-manager) instance. You can access this instance through the `credentialsManager` property.

```dart
final credentials = await auth0.credentialsManager.credentials();
```

For other comprehensive examples, see the [EXAMPLES.md](EXAMPLES.md) document.

#### 🌐 Web

Start by calling the `onLoad()` method in your app's `initState()`.

```dart
@override
  void initState() {
    super.initState();

    if (kIsWeb) {
      auth0Web.onLoad().then((final credentials) => {
        if (credentials != null) {
          // Logged in!
          // auth0_flutter automatically stores the user's credentials in the
          // built-in cache.
          //
          // Access token -> credentials.accessToken
          // User profile -> credentials.user
        } else {
          // Not logged in
        }
      });
    }
  }
```

Then, redirect to the [Universal Login](https://auth0.com/docs/authenticate/login/auth0-universal-login) page in the `onPressed` callback of your **Login** button.

```dart
if (kIsWeb) {
  await auth0Web.loginWithRedirect(redirectUrl: 'http://localhost:3000');
}
```

<details>
  <summary>Using a popup</summary>

Instead of redirecting to the Universal Login page, you can open it in a popup window.

```dart
if (kIsWeb) {
  final credentials = await auth0Web.loginWithPopup();
}
```

To provide your own popup window, create it using the `window.open()` HTML API and set `popupWindow` to the result.
You may want to do this if certain browsers (like Safari) block the popup by default; in this scenario, creating your own and passing it to `loginWithPopup()` may fix it.

```dart
final popup = window.open('', '', 'width=400,height=800');
final credentials = await auth0Web.loginWithPopup(popupWindow: popup);
```

> ⚠️ This requires that `dart:html` be imported into the plugin package, which may generate [the warning](https://dart-lang.github.io/linter/lints/avoid_web_libraries_in_flutter.html) 'avoid_web_libraries_in_flutter'.

</details>

> 💡 You need to import the `'flutter/foundation.dart'` library to access the `kIsWeb` constant. If your app does not support other platforms, you can remove this condition.

For other comprehensive examples, see the [EXAMPLES.md](EXAMPLES.md) document.

### iOS SSO Alert Box

![Screenshot of the SSO alert box](https://user-images.githubusercontent.com/5055789/198689762-8f3459a7-fdde-4c14-a13b-68933ef675e6.png)

Check the [FAQ](FAQ.md) for more information about the alert box that pops up **by default** when using web authentication on iOS.

> 💡 See also [this blog post](https://developer.okta.com/blog/2022/01/13/mobile-sso) for a detailed overview of Single Sign-On (SSO) on iOS.

### Common Tasks

### 📱 Mobile/macOS

- [Check for stored credentials](EXAMPLES.md#check-for-stored-credentials) - check if the user is already logged in when your app starts up.
- [Retrieve stored credentials](EXAMPLES.md#retrieve-stored-credentials) - fetch the user's credentials from the storage, automatically renewing them if they have expired.
- [Retrieve user information](EXAMPLES.md#retrieve-user-information) - fetch the latest user information from the `/userinfo` endpoint.

### 🌐 Web

- [Handling credentials on the web](EXAMPLES.md#handling-credentials-on-the-web) - how to check and retrieve credentials on the web platform.

## API reference

### 📱 Mobile/macOS

#### Web Authentication

- [login](https://pub.dev/documentation/auth0_flutter/latest/auth0_flutter/WebAuthentication/login.html)
- [logout](https://pub.dev/documentation/auth0_flutter/latest/auth0_flutter/WebAuthentication/logout.html)

#### API

- [login](https://pub.dev/documentation/auth0_flutter/latest/auth0_flutter/AuthenticationApi/login.html)
- [loginWithOtp](https://pub.dev/documentation/auth0_flutter/latest/auth0_flutter/AuthenticationApi/loginWithOtp.html)
- [multifactorChallenge](https://pub.dev/documentation/auth0_flutter/latest/auth0_flutter/AuthenticationApi/multifactorChallenge.html)
- [renewCredentials](https://pub.dev/documentation/auth0_flutter/latest/auth0_flutter/AuthenticationApi/renewCredentials.html)
- [resetPassword](https://pub.dev/documentation/auth0_flutter/latest/auth0_flutter/AuthenticationApi/resetPassword.html)
- [signup](https://pub.dev/documentation/auth0_flutter/latest/auth0_flutter/AuthenticationApi/signup.html)
- [userProfile](https://pub.dev/documentation/auth0_flutter/latest/auth0_flutter/AuthenticationApi/userProfile.html)

#### Credentials Manager

- [credentials](https://pub.dev/documentation/auth0_flutter/latest/auth0_flutter/DefaultCredentialsManager/credentials.html)
- [hasValidCredentials](https://pub.dev/documentation/auth0_flutter/latest/auth0_flutter/DefaultCredentialsManager/hasValidCredentials.html)
- [storeCredentials](https://pub.dev/documentation/auth0_flutter/latest/auth0_flutter/DefaultCredentialsManager/storeCredentials.html)
- [clearCredentials](https://pub.dev/documentation/auth0_flutter/latest/auth0_flutter/DefaultCredentialsManager/clearCredentials.html)

### 🌐 Web

- [loginWithRedirect](https://pub.dev/documentation/auth0_flutter/latest/auth0_flutter_web/Auth0Web/loginWithRedirect.html)
- [loginWithPopup](https://pub.dev/documentation/auth0_flutter/latest/auth0_flutter_web/Auth0Web/loginWithPopup.html)
- [onLoad](https://pub.dev/documentation/auth0_flutter/latest/auth0_flutter_web/Auth0Web/onLoad.html)
- [logout](https://pub.dev/documentation/auth0_flutter/latest/auth0_flutter_web/Auth0Web/logout.html)
- [credentials](https://pub.dev/documentation/auth0_flutter/latest/auth0_flutter_web/Auth0Web/credentials.html)
- [hasValidCredentials](https://pub.dev/documentation/auth0_flutter/latest/auth0_flutter_web/Auth0Web/hasValidCredentials.html)

## Feedback

### Contributing

We appreciate feedback and contribution to this repo! Before you get started, please see the following:

- [Auth0's general contribution guidelines](https://github.com/auth0/open-source-template/blob/master/GENERAL-CONTRIBUTING.md)
- [Auth0's code of conduct guidelines](https://github.com/auth0/open-source-template/blob/master/CODE-OF-CONDUCT.md)

### Raise an issue

To provide feedback or report a bug, please [raise an issue on our issue tracker](https://github.com/auth0/auth0-flutter/issues).

### Vulnerability Reporting

Please do not report security vulnerabilities on the public GitHub issue tracker. The [Responsible Disclosure Program](https://auth0.com/responsible-disclosure-policy) details the procedure for disclosing security issues.

---

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: light)" srcset="https://cdn.auth0.com/website/sdks/logos/auth0_light_mode.png" width="150">
    <source media="(prefers-color-scheme: dark)" srcset="https://cdn.auth0.com/website/sdks/logos/auth0_dark_mode.png" width="150">
    <img alt="Auth0 Logo" src="https://cdn.auth0.com/website/sdks/logos/auth0_light_mode.png" width="150">
  </picture>
</p>

<p align="center">Auth0 is an easy-to-implement, adaptable authentication and authorization platform. To learn more check out <a href="https://auth0.com/why-auth0">Why Auth0?</a></p>

<p align="center">This project is licensed under the MIT license. See the <a href="./LICENSE"> LICENSE</a> file for more info.</p>
