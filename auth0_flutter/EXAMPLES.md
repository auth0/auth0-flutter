# Examples

- [📱 Web Authentication](#-web-authentication)
  - [Log out](#log-out)
  - [Sign up](#sign-up)
  - [Adding an audience](#adding-an-audience)
  - [Adding scopes](#adding-scopes)
  - [Adding custom parameters](#adding-custom-parameters)
  - [ID token validation](#id-token-validation)
  - [Using `SFSafariViewController` (iOS only)](#using-sfsafariviewcontroller-ios-only)
    - [1. Configure a custom URL scheme](#1-configure-a-custom-url-scheme)
    - [2. Capture the callback URL](#2-capture-the-callback-url)
  - [Errors](#errors)
  - [Android: Custom schemes](#android-custom-schemes)
- [📱 Credentials Manager](#-credentials-manager)
  - [Check for stored credentials](#check-for-stored-credentials)
  - [Retrieve stored credentials](#retrieve-stored-credentials)
  - [Custom implementations](#custom-implementations)
  - [Local authentication](#local-authentication)
  - [Disable credentials storage](#disable-credentials-storage)
  - [Errors](#errors-1)
- [🌐 Handling Credentials on the Web](#-handling-credentials-on-the-web)
  - [Check for valid credentials](#check-for-valid-credentials)
  - [Retrieve stored credentials](#retrieve-stored-credentials-1)
- [📱 Authentication API](#-authentication-api)
  - [Login with database connection](#login-with-database-connection)
  - [Sign up with database connection](#sign-up-with-database-connection)
  - [Retrieve user information](#retrieve-user-information)
  - [Renew credentials](#renew-credentials)
  - [Errors](#errors-2)
- [🌐📱 Organizations](#-organizations)
  - [Log in to an organization](#log-in-to-an-organization)
  - [Accept user invitations](#accept-user-invitations)
- [📱 Bot detection](#-bot-detection)

## 📱 Web Authentication

  - [Log out](#log-out)
  - [Sign up](#sign-up)
  - [Adding an audience](#adding-an-audience)
  - [Adding scopes](#adding-scopes)
  - [Adding custom parameters](#adding-custom-parameters)
  - [ID token validation](#id-token-validation)
  - [Using `SFSafariViewController` (iOS only)](#using-sfsafariviewcontroller-ios-only)
    - [1. Configure a custom URL scheme](#1-configure-a-custom-url-scheme)
    - [2. Capture the callback URL](#2-capture-the-callback-url)
  - [Errors](#errors)
  - [Android: Custom schemes](#android-custom-schemes)

---

### Log out

Logging the user out involves clearing the Universal Login session cookie and then deleting the user's credentials from your app.

Call the `logout()` method in the `onPressed` callback of your **Logout** button. Once the session cookie has been cleared, `auth0_flutter` will automatically delete the user's credentials.

<details>
  <summary>Mobile</summary>

If you're using your own credentials storage, make sure to delete the credentials afterward.

```dart
// Use a Universal Link logout URL on iOS 17.4+ / macOS 14.4+
// useHTTPS is ignored on Android
await auth0.webAuthentication().logout(useHTTPS: true);
```

</details>

<details>
  <summary>Web</summary>

```dart
if (kIsWeb) {
  await auth0Web.logout(returnToUrl: 'http://localhost:3000');
}
```

> 💡 You need to import the `'flutter/foundation.dart'` library to access the `kIsWeb` constant. If your app does not support other platforms, you can remove this condition.

</details>

### Sign up

You can make users land directly on the Signup page instead of the Login page by specifying the `'screen_hint': 'signup'` parameter. Note that this can be combined with `'prompt': 'login'`, which indicates whether you want to always show the authentication page or you want to skip if there's an existing session.

| Parameters                                   | No existing session   | Existing session              |
| :------------------------------------------- | :-------------------- | :---------------------------- |
| No extra parameters                          | Shows the login page  | Redirects to the callback URL |
| `'screen_hint': 'signup'`                    | Shows the signup page | Redirects to the callback URL |
| `'prompt': 'login'`                          | Shows the login page  | Shows the login page          |
| `'prompt': 'login', 'screen_hint': 'signup'` | Shows the signup page | Shows the signup page         |

<details>
  <summary>Mobile</summary>

```dart
final credentials = await auth0
    .webAuthentication()
    .login(parameters: {'screen_hint': 'signup'});
```

</details>

<details>
  <summary>Web</summary>

```dart
await auth0Web.loginWithRedirect(
    redirectUrl: 'http://localhost:3000',
    parameters: {'screen_hint': 'signup'});
```

</details>

> ⚠️ The `screen_hint` parameter will work with the **New Universal Login Experience** without any further configuration. If you are using the **Classic Universal Login Experience**, you need to customize the [login template](https://manage.auth0.com/#/login_page) to look for this parameter and set the `initialScreen` [option](https://github.com/auth0/lock#database-options) of the `Auth0Lock` constructor.

### Adding an audience

Specify an [audience](https://auth0.com/docs/secure/tokens/access-tokens/get-access-tokens#control-access-token-audience) value to obtain an access token that can be used to make authenticated requests to a backend. The audience value is the **API Identifier** of your [Auth0 API](https://auth0.com/docs/get-started/apis), for example `https://example.com/api`.

<details>
  <summary>Mobile</summary>

```dart
final credentials = await auth0
    .webAuthentication()
    .login(audience: 'YOUR_AUTH0_API_IDENTIFIER');
```

</details>

<details>
  <summary>Web</summary>

```dart
await auth0Web.loginWithRedirect(
    redirectUrl: 'http://localhost:3000',
    audience: 'YOUR_AUTH0_API_IDENTIFIER');
```

</details>

### Adding scopes

Specify [scopes](https://auth0.com/docs/get-started/apis/scopes) to request permission to access protected resources, like the user profile.

<details>
  <summary>Mobile</summary>

The default scope values are  `openid`, `profile`, `email`, and `offline_access`. Regardless of the values specified, `openid` is always included.

```dart
final credentials = await auth0
    .webAuthentication()
    .login(scopes: {'profile', 'email', 'offline_access', 'read:todos'});
```

</details>

<details>
  <summary>Web</summary>

The default scope values are  `openid`, `profile`, and `email`. Regardless of the values specified, `openid` is always included.

```dart
await auth0Web.loginWithRedirect(
    redirectUrl: 'http://localhost:3000',
    scopes: {'profile', 'email', 'read:todos'});
```

</details>

### Adding custom parameters

Specify additional parameters by passing a `parameters` map.

<details>
  <summary>Mobile</summary>

```dart
final credentials = await auth0
    .webAuthentication()
    .login(parameters: {'connection': 'github'});
```

</details>

<details>
  <summary>Web</summary>

Custom parameters can be configured globally.

```dart
await auth0Web.onLoad(
    parameters: {'connection': 'github'});
```

Custom parameters can be configured when calling `loginWithRedirect`. Any globally configured parameter (passed to `onLoad()`) can be overriden when passing the same custom parameter to `loginWithRedirect`.

```dart
await auth0Web.loginWithRedirect(
    redirectUrl: 'http://localhost:3000',
    parameters: {'connection': 'github'});
```

</details>

### ID token validation

`auth0_flutter` automatically [validates](https://auth0.com/docs/secure/tokens/id-tokens/validate-id-tokens) the ID token obtained from Web Auth login, following the [OpenID Connect specification](https://openid.net/specs/openid-connect-core-1_0.html). This ensures the contents of the ID token have not been tampered with and can be safely used.

<details>
  <summary>Mobile</summary>

You can configure the ID token validation by passing an `IdTokenValidationConfig` instance. Check the [API documentation](https://pub.dev/documentation/auth0_flutter_platform_interface/latest/auth0_flutter_platform_interface/IdTokenValidationConfig-class.html) to learn more about the available configuration options.

```dart
const config = IdTokenValidationConfig(leeway: 180);
final credentials =
    await auth0.webAuthentication().login(idTokenValidationConfig: config);
```

</details>

<details>
  <summary>Web</summary>

You can configure `issuer` and `leeway` values through the `onLoad()` method.

```dart
auth0Web
    .onLoad(issuer: 'https://example.com/', leeway: 180)
    .then((final credentials) {
  // ...
});
```

The `max_age` value can be configured through `loginWithRedirect()` and `loginWithPopup()`.

```dart
await auth0Web.loginWithRedirect(
    redirectUrl: 'http://localhost:3000',
    maxAge: 7200);
```

</details>

### Using `SFSafariViewController` (iOS only)

auth0_flutter supports using `SFSafariViewController` as the browser instead of `ASWebAuthenticationSession`. Note that it can only be used for login, not for logout. According to its docs, `SFSafariViewController` must be used "to visibly present information to users":

![Screenshot of SFSafariViewController's documentation](https://github.com/auth0/auth0-flutter/assets/5055789/952aa669-f229-4e6e-bb7e-527b701bdea6)

This is the case for login, but not for logout. Instead of calling `logout()`, you can delete the stored credentials –using the Credentials Manager's `clearCredentials()` method– and use `'prompt': 'login'` to force the login page even if the session cookie is still present. Since the cookies stored by `SFSafariViewController` are scoped to your app, this should not pose an issue.

```dart
await auth0.webAuthentication().login(
      safariViewController: const SafariViewController(),
      parameters: {'prompt': 'login'}); // Ignore the cookie (if present) and show the login page
```

> 💡 `SFSafariViewController` does not support using a Universal Link as callback URL. See https://auth0.github.io/Auth0.swift/documentation/auth0/useragents to learn more about the differences between `ASWebAuthenticationSession` and `SFSafariViewController`.

If you choose to use `SFSafariViewController`, you need to perform an additional bit of setup. Unlike `ASWebAuthenticationSession`, `SFSafariViewController` will not automatically capture the callback URL when Auth0 redirects back to your app, so it is necessary to manually resume the login operation.

#### 1. Configure a custom URL scheme

There is an `Info.plist` file in the `ios/Runner` (or `macos/Runner`, for macOS) directory of your app. Open it and add the following snippet inside the top-level `<dict>` tag. This registers your iOS/macOS bundle identifier as a custom URL scheme, so the callback URL can reach your app.

```xml
<!-- Info.plist -->

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

> 💡 If you're opening the `Info.plist` file in Xcode and it is not being shown in this format, you can **Right Click** on `Info.plist` in the Xcode [project navigator](https://developer.apple.com/documentation/bundleresources/information_property_list/managing_your_app_s_information_property_list) and then select **Open As > Source Code**.

#### 2. Capture the callback URL

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

### Errors

<details>
  <summary>Mobile</summary>

Web Auth will only throw `WebAuthenticationException` exceptions. Check the [API documentation](https://pub.dev/documentation/auth0_flutter_platform_interface/latest/auth0_flutter_platform_interface/WebAuthenticationException-class.html) to learn more about the available `WebAuthenticationException` properties.

```dart
try {
  final credentials = await auth0.webAuthentication().login();
  // ...
} on WebAuthenticationException catch (e) {
  print(e);
}
```

</details>

<details>
  <summary>Web</summary>

The web implementation will only throw `WebException` exceptions. Check the [API documentation](https://pub.dev/documentation/auth0_flutter_platform_interface/latest/auth0_flutter_platform_interface/WebException-class.html) to learn more about the available `WebException` properties.

```dart
try {
  await auth0Web.loginWithRedirect(redirectUrl: 'http://localhost:3000');
} on WebException catch (e) {
  print(e);
}
```

</details>

### Android: Custom schemes

On Android, `https` is used by default as the callback URL scheme. This works best for Android API 23+ if you're using [Android App Links](https://auth0.com/docs/get-started/applications/enable-android-app-links-support), but in previous Android versions, this may show the intent chooser dialog prompting the user to choose either your app or the browser. You can change this behavior by using a custom unique scheme so that Android opens the link directly with your app.

1. Update the `auth0Scheme` manifest placeholder on the `android/build.gradle` file.
2. Update the **Allowed Callback URLs** in the settings page of your [Auth0 application](https://manage.auth0.com/#/applications/).
3. Pass the scheme value to the `webAuthentication()` method.

```dart
final webAuth = auth0.webAuthentication(scheme: 'YOUR_CUSTOM_SCHEME');

// Login
final credentials = await webAuth.login();

// Logout
await webAuth.logout();
```

> 💡 Note that custom schemes [can only have](https://developer.android.com/guide/topics/manifest/data-element) lowercase letters.

[Go up ⤴](#examples)

## 📱 Credentials Manager

> This feature is mobile/desktop only; on web, the [SPA SDK](https://github.com/auth0/auth0-spa-js) used by auth0_flutter keeps its own cache. See [Handling Credentials on the Web](#handling-credentials-on-the-web) for more details.

- [Check for stored credentials](#check-for-stored-credentials)
- [Retrieve stored credentials](#retrieve-stored-credentials)
- [Custom implementations](#custom-implementations)
- [Local authentication](#local-authentication)
- [Credentials Manager errors](#credentials-manager-errors)
- [Disable credentials storage](#disable-credentials-storage)

The Credentials Manager utility allows you to securely store and retrieve the user's credentials. The credentials will be stored encrypted in Shared Preferences on Android, and in the Keychain on iOS/macOS.

> 💡 If you're using Web Auth, you do not need to manually store the credentials after login and delete them after logout; auth0_flutter does it automatically.

### Check for stored credentials

When the users open your app, check for valid credentials. If they exist, you can retrieve them and redirect the users to the app's main flow without any additional login steps.

```dart
final isLoggedIn = await auth0.credentialsManager.hasValidCredentials();

if (isLoggedIn) {
  // Retrieve the credentials and redirect to the main flow
} else {
  // No valid credentials exist, present the login page
}
```

### Retrieve stored credentials

The credentials will be automatically renewed (if expired) using the [refresh token](https://auth0.com/docs/secure/tokens/refresh-tokens). **This method is thread-safe.**

```dart
final credentials = await auth0.credentialsManager.credentials();
```

> 💡 You do not need to call `credentialsManager.storeCredentials()` afterward. The Credentials Manager automatically persists the renewed credentials.

### Custom implementations

flutter_auth0 exposes a built-in, default Credentials Manager implementation through the `credentialsManager` property. You can pass your own implementation to the `Auth0` constructor. If you're using Web Auth, this implementation will be used to store the user's credentials after login and delete them after logout.

```dart
final customCredentialsManager = CustomCredentialsManager();
final auth0 = Auth0('YOUR_AUTH0_DOMAIN', 'YOUR_AUTH0_CLIENT_ID',
    credentialsManager: customCredentialsManager);
// auth0.credentialsManager is now your CustomCredentialsManager instance
```

### Local authentication

You can enable an additional level of user authentication before retrieving credentials using the local authentication supported by the device, for example PIN or fingerprint on Android, and Face ID or Touch ID on iOS.

```dart
const localAuthentication =
    LocalAuthentication(title: 'Please authenticate to continue');
final auth0 = Auth0('YOUR_AUTH0_DOMAIN', 'YOUR_AUTH0_CLIENT_ID',
    localAuthentication: localAuthentication);
final credentials = await auth0.credentialsManager.credentials();
```

Check the [API documentation](https://pub.dev/documentation/auth0_flutter_platform_interface/latest/auth0_flutter_platform_interface/LocalAuthentication-class.html) to learn more about the available `LocalAuthentication` properties.

> ⚠️ Enabling local authentication will not work if you're using a custom Credentials Manager implementation. In that case, you will need to build support for local authentication into your custom implementation.

### Disable credentials storage

By default, `auth0_flutter` will automatically store the user's credentials after login and delete them after logout, using the built-in [Credentials Manager](#credentials-manager) instance. If you prefer to use your own credentials storage, you need to disable the built-in Credentials Manager.

```dart
final credentials =
    await auth0.webAuthentication(useCredentialsManager: false).login();
```

### Errors

The Credentials Manager will only throw `CredentialsManagerException` exceptions. You can find more information in the `details` property of the exception. Check the [API documentation](https://pub.dev/documentation/auth0_flutter_platform_interface/latest/auth0_flutter_platform_interface/CredentialsManagerException-class.html) to learn more about the available `CredentialsManagerException` properties.

```dart
try {
  final credentials = await auth0.credentialsManager.credentials();
  // ...
} on CredentialsManagerException catch (e) {
  print(e);
}
```

[Go up ⤴](#examples)

## 🌐 Handling Credentials on the Web

> This section describes handling credentials for the web platform. For mobile/desktop, see [Credentials Manager](#-credentials-manager).

The management and storage of credentials is handled internally by the underlying [Auth0 SPA SDK](https://github.com/auth0/auth0-spa-js), including refreshing the access token when it expires. The Flutter SDK provides an API for checking whether credentials are available, and the retrieval of those credentials.

### Check for valid credentials

```dart
final isLoggedIn = await auth0Web.hasValidCredentials();

if (isLoggedIn) {
  // Retrieve the credentials and redirect to the main flow
} else {
  // No valid credentials exist, present the login page
}
```

### Retrieve stored credentials

Credentials can be retrieved on application start using `onLoad()`:

```dart
auth0Web.onLoad().then((final credentials) {
  if (credentials != null) {
    // logged in!
  }
});
```

They can also be retrieved at any time using `credentials()`:

```dart
final credentials = await auth0Web.credentials();
```

[Go up ⤴](#examples)

## 📱 Authentication API

> This feature is mobile/desktop only; the [SPA SDK](https://github.com/auth0/auth0-spa-js) used by auth0_flutter does not include an API client.

- [Login with database connection](#login-with-database-connection)
- [Sign up with database connection](#sign-up-with-database-connection)
- [Retrieve user information](#retrieve-user-information)
- [Renew credentials](#renew-credentials)
- [API client errors](#api-client-errors)

The Authentication API exposes the AuthN/AuthZ functionality of Auth0, as well as the supported identity protocols like OpenID Connect, OAuth 2.0, and SAML.
We recommend using [Universal Login](https://auth0.com/docs/authenticate/login/auth0-universal-login), but if you prefer to build your own UI you can use our API endpoints to do so. However, some Auth flows (grant types) are disabled by default so you must enable them on the settings page of your [Auth0 application](https://manage.auth0.com/#/applications/), as explained in [Update Grant Types](https://auth0.com/docs/get-started/applications/update-grant-types).

To log in or sign up with a username and password, the `Password` grant type needs to be enabled in your app. If you set the grants via the Management API you should activate both `http://auth0.com/oauth/grant-type/password-realm` and `Password`. Otherwise, the Auth0 Dashboard will take care of activating both when enabling `Password`.

> 💡 If your Auth0 account has the **Bot Detection** feature enabled, your requests might be flagged for verification. Check how to handle this scenario in the [Bot Detection](#bot-detection) section.

> ⚠️ The ID tokens obtained from Web Auth login are automatically validated by `auth0_flutter`, ensuring their contents have not been tampered with. **This is not the case for the ID tokens obtained from the Authentication API client**, including the ones received when renewing the credentials using the refresh token. You must [validate](https://auth0.com/docs/secure/tokens/id-tokens/validate-id-tokens) any ID tokens received from the Authentication API client before using the information they contain.

### Login with database connection

```dart
final credentials = await auth0.api.login(
    usernameOrEmail: 'jane.smith@example.com',
    password: 'secret-password',
    connectionOrRealm: 'Username-Password-Authentication');

// Store the credentials afterward
final didStore =
    await auth0.credentialsManager.storeCredentials(credentials);
```

<details>
  <summary>Add an audience value</summary>

Specify an [audience](https://auth0.com/docs/secure/tokens/access-tokens/get-access-tokens#control-access-token-audience) to obtain an access token that can be used to make authenticated requests to a backend. The audience value is the **API Identifier** of your [Auth0 API](https://auth0.com/docs/get-started/apis), for example `https://example.com/api`.

```dart
final credentials = await auth0.api.login(
    usernameOrEmail: 'jane.smith@example.com',
    password: 'secret-password',
    connectionOrRealm: 'Username-Password-Authentication',
    audience: 'YOUR_AUTH0_API_IDENTIFIER');
```

</details>

<details>
  <summary>Add scope values</summary>

Specify [scopes](https://auth0.com/docs/get-started/apis/scopes) to request permission to access protected resources, like the user profile. The default scope values are `openid`, `profile`, `email`, and `offline_access`. Regardless of the values specified, `openid` is always included.

```dart
final credentials = await auth0.api.login(
    usernameOrEmail: 'jane.smith@example.com',
    password: 'secret-password',
    connectionOrRealm: 'Username-Password-Authentication',
    scopes: {'profile', 'email', 'offline_access', 'read:todos'});
```

</details>

### Sign up with database connection

```dart
final databaseUser = await auth0.api.signup(
    email: 'jane.smith@example.com',
    password: 'secret-password',
    connection: 'Username-Password-Authentication',
    userMetadata: {'first_name': 'Jane', 'last_name': 'Smith'});
```

> 💡 You might want to log the user in after signup. See [Login with database connection](#login-with-database-connection) above for an example.

### Retrieve user information

Fetch the latest user information from the `/userinfo` endpoint.

This method will yield a `UserProfile` instance. Check the [API documentation](https://pub.dev/documentation/auth0_flutter_platform_interface/latest/auth0_flutter_platform_interface/UserProfile-class.html) to learn more about its available properties.

```dart
final userProfile = await auth0.api.userInfo(accessToken: accessToken);
```

### Renew credentials

Use a [refresh token](https://auth0.com/docs/secure/tokens/refresh-tokens) to renew the user's credentials. It's recommended that you read and understand the refresh token process beforehand.

```dart
final newCredentials =
    await auth0.api.renewCredentials(refreshToken: refreshToken);

// Store the credentials afterward
final didStore =
    await auth0.credentialsManager.storeCredentials(newCredentials);
```

> 💡 To obtain a refresh token, make sure your Auth0 application has the **refresh token** [grant enabled](https://auth0.com/docs/get-started/applications/update-grant-types). If you are also specifying an audience value, make sure that the corresponding Auth0 API has the **Allow Offline Access** [setting enabled](https://auth0.com/docs/get-started/apis/api-settings#access-settings).

### Errors

The Authentication API client will only throw `ApiException` exceptions. You can find more information in the `details` property of the exception. Check the [API documentation](https://pub.dev/documentation/auth0_flutter_platform_interface/latest/auth0_flutter_platform_interface/ApiException-class.html) to learn more about the available `ApiException` properties.

```dart
try {
  final credentials = await auth0.api.login(
      usernameOrEmail: email,
      password: password,
      connectionOrRealm: connection);
  // ...
} on ApiException catch (e) {
  print(e);
}
```

[Go up ⤴](#examples)

## 🌐📱 Organizations

[Organizations](https://auth0.com/docs/manage-users/organizations) is a set of features that provide better support for developers who build and maintain SaaS and Business-to-Business (B2B) applications.

> 💡 Organizations is currently only available to customers on our Enterprise and Startup subscription plans.

### Log in to an organization

<details>
  <summary>Mobile</summary>

```dart
final credentials = await auth0
    .webAuthentication()
    .login(organizationId: 'YOUR_AUTH0_ORGANIZATION_ID');
```

</details>

<details>
  <summary>Web</summary>

```dart
await auth0Web.loginWithRedirect(
    redirectUrl: 'http://localhost:3000',
    organizationId: 'YOUR_AUTH0_ORGANIZATION_ID');
```

</details>

### Accept user invitations

To accept organization invitations your app needs to support [deep linking](https://docs.flutter.dev/development/ui/navigation/deep-linking), as invitation links are HTTPS-only. Tapping on the invitation link should open your app.

When your app gets opened by an invitation link, grab the invitation URL and pass it to the login method.

<details>
  <summary>Mobile</summary>

```dart
final credentials =
    await auth0.webAuthentication().login(invitationUrl: url);
```

</details>

<details>
  <summary>Web</summary>

```dart
await auth0Web.loginWithRedirect(
    redirectUrl: 'http://localhost:3000',
    invitationUrl: url);
```

</details>

[Go up ⤴](#examples)

## 📱 Bot detection

> This example is mobile/desktop only; the [SPA SDK](https://github.com/auth0/auth0-spa-js) used by auth0_flutter does not include an API client.

If you are performing database login/signup via the Authentication API and would like to use the [Bot Detection](https://auth0.com/docs/secure/attack-protection/bot-detection) feature, you need to handle the `isVerificationRequired` error. It indicates that the request was flagged as suspicious and an additional verification step is necessary to log the user in. That verification step is web-based, so you need to use Web Auth to complete it.

```dart
try {
  final credentials = await auth0.api.login(
      usernameOrEmail: email,
      password: password,
      connectionOrRealm: connection,
      scopes: scopes);
  // ...
} on ApiException catch (e) {
  if (e.isVerificationRequired) {
    final credentials = await auth0.webAuthentication().login(
        scopes: scopes,
        useEphemeralSession: true, // Otherwise a session cookie will remain (iOS/macOS only)
        parameters: {
          'connection': connection,
          'login_hint': email // So the user doesn't have to type it again
        });
    // ...
  }
}
```

---

[Go up ⤴](#examples)
