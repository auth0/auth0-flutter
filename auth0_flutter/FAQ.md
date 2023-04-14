# Frequently Asked Questions

- [📱 Mobile](#-mobile)
  - [1. How can I have separate Auth0 domains for each environment on Android?](#1-how-can-i-have-separate-auth0-domains-for-each-environment-on-android)
  - [2. How can I disable the iOS _login_ alert box?](#2-how-can-i-disable-the-ios-login-alert-box)
    - [Use ephemeral sessions](#use-ephemeral-sessions)
    - [Use `SFSafariViewController`](#use-sfsafariviewcontroller)
  - [3. How can I disable the iOS _logout_ alert box?](#3-how-can-i-disable-the-ios-logout-alert-box)
  - [4. How can I change the message in the iOS alert box?](#4-how-can-i-change-the-message-in-the-ios-alert-box)
  - [5. How can I programmatically close the iOS alert box?](#5-how-can-i-programmatically-close-the-ios-alert-box)
- [🖥️ Web](#️-web)
  - [1. Why is the user logged out when they refresh the page in their SPA?](#1-why-is-the-user-logged-out-when-they-refresh-the-page-in-their-spa)
    - [Using Multi-factor Authentication (MFA)](#using-multi-factor-authentication-mfa)
  - [2. Why do I get `auth0-spa-js must run on a secure origin`?](#2-why-do-i-get-auth0-spa-js-must-run-on-a-secure-origin)

## 📱 Mobile

This library uses [Auth0.Android](https://github.com/auth0/Auth0.Android) on Android, and [Auth0.swift](https://github.com/auth0/Auth0.swift) on iOS.

### 1. How can I have separate Auth0 domains for each environment on Android?

Auth0.Android declares a `RedirectActivity` along with an **intent-filter** in its Android Manifest file to handle the Web Auth callback and logout URLs. While this approach prevents the developer from adding an activity declaration to their app's Android Manifest file, it requires the use of [manifest placeholders](https://developer.android.com/studio/build/manage-manifests#inject_build_variables_into_the_manifest).

Alternatively, you can re-declare the `RedirectActivity` in the `android/app/src/main/AndroidManifest.xml` file with your own **intent-filter** so it overrides the library's default one. If you do this, the `manifestPlaceholders` don't need to be set as long as the activity contains `tools:node="replace"` like in the snippet below.

```xml
<!-- android/src/main/AndroidManifest.xml -->

<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools"
    package="com.company.myapp">
    <application android:theme="@style/AppTheme">
        <!-- ... -->

        <activity
            android:name="com.auth0.react.RedirectActivity"
            tools:node="replace">
            <intent-filter
                android:autoVerify="true"
                tools:targetApi="m">
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
                <!-- add a data tag for each environment -->
                <data
                    android:host="example.com"
                    android:pathPrefix="/android/${applicationId}/callback"
                    android:scheme="${auth0Scheme}" />
                <data
                    android:host="qa.example.com"
                    android:pathPrefix="/android/${applicationId}/callback"
                    android:scheme="${auth0Scheme}" />
            </intent-filter>
        </activity>

        <!-- ... -->
    </application>
</manifest>
```

### 2. How can I disable the iOS _login_ alert box?

![ios-sso-alert](https://user-images.githubusercontent.com/5055789/198689762-8f3459a7-fdde-4c14-a13b-68933ef675e6.png)

Auth0.swift uses `ASWebAuthenticationSession` to perform web-based authentication, which is the [API provided by Apple](https://developer.apple.com/documentation/authenticationservices/aswebauthenticationsession) for such purpose.

That alert box is displayed and managed by `ASWebAuthenticationSession`, not by Auth0.swift, because by default this API will store the session cookie in the shared Safari cookie jar. This makes Single Sign-On (SSO) possible. According to Apple, that requires user consent.

> **Note**
> See [this blog post](https://developer.okta.com/blog/2022/01/13/mobile-sso) for a detailed overview of SSO on iOS.

#### Use ephemeral sessions

If you don't need SSO, you can disable this behavior by adding `useEphemeralSession: true` to the login call. This will configure `ASWebAuthenticationSession` to not store the session cookie in the shared cookie jar, as if using an incognito browser window. With no shared cookie, `ASWebAuthenticationSession` will not prompt the user for consent.

```dart
// No SSO, therefore no alert box
final credentials =
      await auth0.webAuthentication().login(useEphemeralSession: true);
```

Note that with `useEphemeralSession: true` you don't need to call `logout()` at all. Just clearing the credentials from the app will suffice. What `logout()` does is clear the shared session cookie, so that in the next login call the user gets asked to log in again. But with `useEphemeralSession: true` there will be no shared cookie to remove.

You still need to call `logout()` on Android, though, as `useEphemeralSession` is iOS-only.

> **Warning**
> `useEphemeralSession` relies on the `prefersEphemeralWebBrowserSession` configuration option of `ASWebAuthenticationSession`. This option is only available on [iOS 13+](https://developer.apple.com/documentation/authenticationservices/aswebauthenticationsession/3237231-prefersephemeralwebbrowsersessio), so `useEphemeralSession` will have no effect on iOS 12. To improve the experience for iOS 12 users, see the approach described below.

#### Use `SFSafariViewController`

An alternative is to use `SFSafariViewController` instead of `ASWebAuthenticationSession`. You can do so by setting the `safariViewController` property during login:

```dart
await auth0
    .webAuthentication()
    .login(safariViewController: const SafariViewController());
```

> **Note**
> Since `SFSafariViewController` does not share cookies with the Safari app, SSO will not work either. But it will keep its own cookies, so you can use it to perform SSO between your app and your website as long as you open it inside your app using `SFSafariViewController`. This also means that any feature that relies on the persistence of cookies will work as expected.

If you choose to use `SFSafariViewController`, you need to perform an additional bit of setup. Unlike `ASWebAuthenticationSession`, `SFSafariViewController` will not automatically capture the callback URL when Auth0 redirects back to your app, so it's necessary to manually resume the Web Auth operation.

<details>
  <summary>Using the UIKit app lifecycle</summary>

```swift
// AppDelegate.swift

override func application(_ app: UIApplication,
                 open url: URL,
                 options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
    WebAuthentication.resume(with: url)
    return super.application(application, open: url, options: options);
}
```
</details>

<details>
  <summary>Using the UIKit app lifecycle with Scenes</summary>

```swift
// SceneDelegate.swift

func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    guard let url = URLContexts.first?.url else { return }
    WebAuthentication.resume(with: url)
}
```
</details>

### 3. How can I disable the iOS _logout_ alert box?

![ios-sso-alert](https://user-images.githubusercontent.com/5055789/198689762-8f3459a7-fdde-4c14-a13b-68933ef675e6.png)

Since `logout()` on iOS also needs to use `ASWebAuthenticationSession` to clear the shared session cookie, the same alert box will be displayed. 

If you need SSO and/or are willing to tolerate the alert box on the login call, but would prefer to get rid of it when calling `logout()`, you can simply not call `logout()` and just clear the credentials from the app. This means that the shared session cookie will not be removed, so to get the user to log in again you need to add the `'prompt': 'login'` parameter to the _login_ call.

```dart
final credentials = await auth0.webAuthentication().login(
    useEphemeralSession: true,
    parameters: {
      'prompt': 'login'
    }); // Ignore the cookie (if present) and show the login page
```

Otherwise, the browser modal will close right away and the user will be automatically logged in again, as the cookie will still be there.

> **Warning**
> Keeping the shared session cookie may not be an option if you have strong privacy and/or security requirements, for example in the case of a banking app.

### 4. How can I change the message in the iOS alert box?

This library has no control whatsoever over the alert box. Its contents cannot be changed. Unfortunately, that's a limitation of `ASWebAuthenticationSession`.

### 5. How can I programmatically close the iOS alert box?

This library has no control whatsoever over the alert box. It cannot be closed programmatically. Unfortunately, that's a limitation of `ASWebAuthenticationSession`.

## 🖥️ Web

This library uses the [Auth0 SPA SDK](https://github.com/auth0/auth0-spa-js) on the web platform.

### 1. Why is the user logged out when they refresh the page in their SPA?

After logging in, if the page is refreshed and the user appears logged out, it usually means that the silent authentication step has failed to work.

This could be affected by a couple of things:

- When not using refresh tokens, the SPA SDK relies on third-party cookie support to log in silently. If you're not using refresh tokens, you could be using a browser that blocks third-party cookies by default (Safari, Brave, etc)
- You're using the [classic login experience](https://auth0.com/docs/authenticate/login/auth0-universal-login/classic-experience), and trying to log in using a social provider that uses Auth0's developer keys (see [Limitations of Developer Keys when using Classic Universal Login](https://auth0.com/docs/authenticate/identity-providers/social-identity-providers/devkeys#limitations-of-developer-keys-when-using-universal-login))

Please try these to see if you can get unblocked:

- Try it in a browser like Chrome which does not block third-party cookies by default (yet)
- Use the new login experience, if possible
- Supply the social connection with your own client ID and secret in the Auth0 dashboard

#### Using Multi-factor Authentication (MFA)

By default, the SPA SDK uses the `prompt=none` and `response_mode=web_message` flow for silent auth, which depends on the user's Auth0 session.

If you have **Require Multi-factor Auth** set to `Always` in your [Auth0 Dashboard](https://manage.auth0.com/#/security/mfa), silent authentication from your SPA will fail unless:

- The user is using a one-time code and selects **Remember me for 30 days**
- `allowRememberBrowser` is [configured in a Rule](https://auth0.com/docs/secure/multi-factor-authentication/customize-mfa#change-authentication-request-frequency) and `provider` is set to `google-authenticator`

If silent auth is being used and Auth0 needs interaction from the user to complete the MFA step, then authentication will fail with an `mfa_required` error and the user must log in interactively.

To resolve this:

- Use a Rule to [configure the MFA step](https://auth0.com/docs/secure/multi-factor-authentication/customize-mfa#change-authentication-request-frequency) to allow the user to remember the browser for up to 30 days.
- Use refresh tokens + local storage so that the auto-login on page refresh does not depend on the user's session. Please [read the docs on storage options](https://auth0.com/docs/libraries/auth0-single-page-app-sdk#change-storage-options) and [rotating refresh tokens](https://auth0.com/docs/libraries/auth0-single-page-app-sdk#use-rotating-refresh-tokens) as these change the security profile of your application.

### 2. Why do I get `auth0-spa-js must run on a secure origin`?

Internally, the SPA SDK uses [Web Cryptography API](https://developer.mozilla.org/en-US/docs/Web/API/Web_Crypto_API) to create [SHA-256 digest](https://developer.mozilla.org/en-US/docs/Web/API/SubtleCrypto/digest).

According to the spec ([via Github issues](https://github.com/w3c/webcrypto/issues/28)), Web Cryptography API requires a secure origin, so that accessing `Crypto.subtle` in a not secure context returns `undefined`.

In most browsers, secure origins are origins that match at least one of the following (scheme, host, port) patterns:

```
(https, *, *)
(wss, *, *)
(*, localhost, *)
(*, 127/8, *)
(*, ::1/128, *)
(file, *, —)
```

If you're running your application from a secure origin, it's possible that your browser doesn't support the Web Crypto API. For a compatibility table, please check https://caniuse.com/#feat=mdn-api_subtlecrypto.
