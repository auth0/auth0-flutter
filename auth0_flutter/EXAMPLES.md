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
  - [Using Partial Custom Tabs (Android only)](#using-partial-custom-tabs-android-only)
  - [Errors](#errors)
  - [Android: Custom schemes](#android-custom-schemes)
- [🪟 Windows Web Authentication](#-windows-web-authentication)
  - [Prerequisites](#prerequisites)
    - [1. Install vcpkg and native dependencies](#1-install-vcpkg-and-native-dependencies)
    - [2. Configure your app's CMakeLists.txt](#2-configure-your-apps-cmakeliststxt)
    - [3. Register the custom URL scheme (protocol handler)](#3-register-the-custom-url-scheme-protocol-handler)
    - [4. Update the runner (main.cpp)](#4-update-the-runner-maincpp)
  - [Login](#login)
  - [Logout](#logout)
- [📱 Credentials Manager](#-credentials-manager)
  - [Check for stored credentials](#check-for-stored-credentials)
  - [Retrieve stored credentials](#retrieve-stored-credentials)
  - [Retrieve user profile](#retrieve-user-profile)
  - [Custom implementations](#custom-implementations)
  - [Local authentication](#local-authentication)
  - [Credentials Manager configuration](#credentials-manager-configuration)
  - [Disable credentials storage](#disable-credentials-storage)
  - [Errors](#errors-1)
- [🌐 Handling Credentials on the Web](#-handling-credentials-on-the-web)
  - [Check for valid credentials](#check-for-valid-credentials)
  - [Retrieve stored credentials](#retrieve-stored-credentials-1)
- [📱 Authentication API](#-authentication-api)
  - [Login with database connection](#login-with-database-connection)
  - [Sign up with database connection](#sign-up-with-database-connection)
  - [Log in with passkeys](#log-in-with-passkeys)
  - [Sign up with passkeys](#sign-up-with-passkeys)
  - [Passwordless Login](#passwordless-login)
  - [Retrieve user information](#retrieve-user-information)
  - [Renew credentials](#renew-credentials)
  - [Custom Token Exchange](#custom-token-exchange)
  - [Errors](#errors-2)
- [🌐📱 Organizations](#-organizations)
  - [Log in to an organization](#log-in-to-an-organization)
  - [Accept user invitations](#accept-user-invitations)
- [📱 Bot detection](#-bot-detection)
- [📱 My Account API](#-my-account-api)
  - [Obtaining an access token for the My Account API](#obtaining-an-access-token-for-the-my-account-api)
  - [Listing and managing authentication methods](#listing-and-managing-authentication-methods)
  - [Enrolling a factor with OTP (phone, email, TOTP)](#enrolling-a-factor-with-otp-phone-email-totp)
  - [Enrolling a factor without OTP (push, recovery code)](#enrolling-a-factor-without-otp-push-recovery-code)
  - [Enrolling a passkey](#enrolling-a-passkey)
  - [Using DPoP](#using-dpop)
  - [Errors](#errors-3)
- [🌐📱 Multi-Factor Authentication (MFA)](#-multi-factor-authentication-mfa)
  - [Obtaining an `mfa_token`](#obtaining-an-mfa_token)
  - [Listing authenticators and challenging a factor](#listing-authenticators-and-challenging-a-factor)
  - [Enrolling a new factor](#enrolling-a-new-factor)
  - [Verifying and exchanging for credentials](#verifying-and-exchanging-for-credentials)
  - [Errors](#errors-4)

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
  - [Using Partial Custom Tabs (Android only)](#using-partial-custom-tabs-android-only)
  - [Errors](#errors)
  - [Android: Custom schemes](#android-custom-schemes)
- [🪟 Windows Web Authentication](#-windows-web-authentication)
  - [Prerequisites](#prerequisites)
    - [1. Install vcpkg and native dependencies](#1-install-vcpkg-and-native-dependencies)
    - [2. Configure your app's CMakeLists.txt](#2-configure-your-apps-cmakeliststxt)
    - [3. Register the custom URL scheme (protocol handler)](#3-register-the-custom-url-scheme-protocol-handler)
    - [4. Update the runner (main.cpp)](#4-update-the-runner-maincpp)
  - [Login](#login)
  - [Logout](#logout)

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
  <summary>Windows</summary>

`appCustomURL` is required for logout. It is the custom-scheme URL your Windows app listens on. `returnTo` is optional — if omitted, `appCustomURL` is used in the Auth0 logout URL as well.

```dart
// Option A — direct custom scheme (appCustomURL is used as returnTo too)
await auth0.windowsWebAuthentication().logout(
  appCustomURL: 'myapp://callback',
);

// Option B — intermediary HTTPS server
// Auth0 redirects to the HTTPS URL; the server redirects on to your custom scheme
await auth0.windowsWebAuthentication().logout(
  appCustomURL: 'myapp://callback',
  returnTo: 'https://your-app.example.com/logout',
);
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

### Using Partial Custom Tabs (Android only)

On Android, auth0_flutter supports [Partial Custom Tabs](https://developer.chrome.com/docs/android/custom-tabs/guide-partial-custom-tabs), which display the authentication page as a bottom sheet or side sheet instead of a full-screen browser tab. This requires Chrome 107+ (bottom sheet) or Chrome 120+ (side sheet). On older browsers, the options are ignored and the tab opens full-screen.

```dart
await auth0.webAuthentication().login(
    customTabsOptions: const CustomTabsOptions(
        initialHeight: 700,
        toolbarCornerRadius: 16,
        resizable: false,
        backgroundInteractionEnabled: true,
        allowedBrowsers: ['com.android.chrome'],
    ));
```

The available options are:

| Option | Type | Description |
|--------|------|-------------|
| `initialHeight` | `int?` | Bottom sheet height in dp. Chrome enforces a minimum of 50% of screen height. |
| `resizable` | `bool?` | Whether the user can drag to resize the bottom sheet. Defaults to `true`. |
| `toolbarCornerRadius` | `int?` | Top corner radius in dp (0–16). Only applies in bottom sheet mode. |
| `initialWidth` | `int?` | Side sheet width in dp. Only applies on screens wider than `sideSheetBreakpoint`. |
| `sideSheetBreakpoint` | `int?` | Screen width threshold (dp) to switch between bottom sheet and side sheet. Defaults to the browser's built-in value (typically 840dp). |
| `backgroundInteractionEnabled` | `bool?` | Whether the user can interact with the app behind the partial tab. Defaults to `false`. |
| `allowedBrowsers` | `List<String>` | Allowlist of browser packages for Custom Tabs. |

You can also use `customTabsOptions` during logout:

```dart
await auth0.webAuthentication().logout(
    customTabsOptions: const CustomTabsOptions(
        initialHeight: 500,
        toolbarCornerRadius: 12,
    ));
```

### Errors

<details>
  <summary>Mobile</summary>

Web Auth will only throw `WebAuthenticationException` exceptions. Check the [API documentation](https://pub.dev/documentation/auth0_flutter_platform_interface/latest/auth0_flutter_platform_interface/WebAuthenticationException-class.html) to learn more about the available `WebAuthenticationException` properties.

```dart
try {
  final credentials = await auth0.webAuthentication().login();
  // ...
} on WebAuthenticationException catch (e) {
  if (e.isRetryable) {
    // Transient error (e.g. network issue) — safe to retry
  } else {
    print(e);
  }
}
```

The `isRetryable` property indicates whether the error is transient (e.g. a network outage) and the operation can be retried.

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

> Whenever possible, Auth0 recommends using [Android App Links](https://auth0.com/docs/applications/enable-android-app-links) as a secure way to link directly to content within your app. Custom URL schemes can be subject to [client impersonation attacks](https://datatracker.ietf.org/doc/html/rfc8252#section-8.6).

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

## 🪟 Windows Web Authentication

Windows uses `windowsWebAuthentication()` instead of `webAuthentication()`.

### `appCustomURL` — why it is required

On Windows, the browser cannot directly activate a desktop app the way iOS/Android handle universal links. Instead, the app registers a **custom URL scheme** (e.g. `myapp://callback`) as a protocol handler in the Windows registry. When the browser navigates to that URL, Windows launches (or brings to the front) your Flutter app and passes the URL as a command-line argument — this is the `appCustomURL`.

`appCustomURL` must always be passed. It tells the SDK which URL scheme your app is listening on so it can intercept the browser redirect.

### `redirectUrl` (login) and `returnTo` (logout) — when to pass them

| Scenario | What to pass | What happens |
|----------|-------------|--------------|
| **Simple setup** (recommended) | `appCustomURL` only | Auth0 redirects straight to the custom scheme; `appCustomURL` is used as `redirect_uri` / `returnTo` in the Auth0 URL. Register your scheme (e.g. `myapp://callback`) in your dashboard. |
| **Intermediary HTTPS server** | `appCustomURL` + `redirectUrl` / `returnTo` | Auth0 redirects to your HTTPS server; the server then redirects onward to `appCustomURL`. Register the HTTPS URL in your dashboard. Useful when you want no custom-scheme URL visible in the browser address bar. |

See the [Windows configuration section](README.md#windows-configure-protocol-handler) in the README for the full setup guide, including the required runner changes.

### Prerequisites

Before using `windowsWebAuthentication()`, your Windows Flutter app needs a few one-time setup steps.

#### 1. Install vcpkg and native dependencies

The auth0_flutter Windows plugin depends on native C++ libraries managed by [vcpkg](https://vcpkg.io/). Install vcpkg and set the `VCPKG_ROOT` environment variable:

```powershell
# Clone vcpkg (if you haven't already)
git clone https://github.com/microsoft/vcpkg.git C:\vcpkg
cd C:\vcpkg
.\bootstrap-vcpkg.bat

# Set the environment variable (persist it in System Properties > Environment Variables)
setx VCPKG_ROOT "C:\vcpkg"
```

The plugin's `vcpkg.json` manifest automatically pulls the required packages (`cpprestsdk`, `openssl`, `boost-system`, `boost-date-time`, `boost-regex`) at build time — no manual `vcpkg install` is needed.

#### 2. Configure your app's CMakeLists.txt

Your app's top-level `windows/CMakeLists.txt` must enable vcpkg toolchain integration so that the plugin's native dependencies can be resolved. Add the following **before** the first `project()` call:

```cmake
# windows/CMakeLists.txt

cmake_minimum_required(VERSION 3.14)

# --- vcpkg integration (required for auth0_flutter) ---
if(DEFINED ENV{VCPKG_ROOT} AND EXISTS "$ENV{VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake")
    set(CMAKE_TOOLCHAIN_FILE "$ENV{VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake"
        CACHE STRING "Vcpkg toolchain file")
endif()

project(your_app LANGUAGES CXX)

# ... rest of your CMakeLists.txt ...
```

> ⚠️ The `CMAKE_TOOLCHAIN_FILE` line **must** appear before `project()`. If it appears after, CMake will have already configured the compiler and vcpkg packages will not be found, resulting in build errors like `Could not find a package configuration file provided by "cpprestsdk"`.

#### 3. Register the custom URL scheme (protocol handler)

For Windows to route your custom-scheme callback URLs (e.g. `myapp://callback`) back to your app, you must register the scheme as a protocol handler in the Windows Registry. Choose a scheme name that is unique to your application. This is typically done once when the app is installed.

> 💡 The scheme can be anything you choose — `myapp`, `com.example.myapp`, etc. Use the same value as `appCustomURL` in your Dart code and register it in the Auth0 dashboard's **Allowed Callback URLs** / **Allowed Logout URLs**.

**Option A — Manual registration (development)**

Create a `.reg` file with the following contents and double-click it to import. Replace `myapp` with your chosen scheme and update the executable path:

```reg
Windows Registry Editor Version 5.00

[HKEY_CURRENT_USER\Software\Classes\myapp]
@="URL:myapp Protocol"
"URL Protocol"=""

[HKEY_CURRENT_USER\Software\Classes\myapp\shell]

[HKEY_CURRENT_USER\Software\Classes\myapp\shell\open]

[HKEY_CURRENT_USER\Software\Classes\myapp\shell\open\command]
@="\"C:\\Path\\To\\Your\\App\\your_app.exe\" \"%1\""
```

Replace `C:\Path\To\Your\App\your_app.exe` with the actual path to your built Flutter executable (e.g. `build\windows\x64\runner\Release\your_app.exe`).

> 💡 During development you can point this at your debug build path. Remember to update it when you move to a release/installed location.

**Option B — Programmatic registration (installer / first-run)**

If you use an installer (MSIX, Inno Setup, WiX, etc.), add the registry entries as part of the install step. For MSIX, declare the protocol in your `Package.appxmanifest`:

```xml
<Extensions>
  <uap:Extension Category="windows.protocol">
    <uap:Protocol Name="myapp">
      <uap:DisplayName>My App Callback</uap:DisplayName>
    </uap:Protocol>
  </uap:Extension>
</Extensions>
```

For a first-run self-registration approach, you can write the registry keys programmatically from your app's `main.cpp`. Replace `myapp` with your chosen scheme:

```cpp
// Call once on first launch to register the protocol handler.
// schemeName: your custom scheme (e.g. L"myapp")
// exePath:    full path to the running executable
void RegisterProtocolHandler(const std::wstring& schemeName,
                             const std::wstring& exePath) {
    HKEY hKey;
    std::wstring keyPath = L"Software\\Classes\\" + schemeName;

    RegCreateKeyExW(HKEY_CURRENT_USER, keyPath.c_str(), 0, NULL,
                    0, KEY_WRITE, NULL, &hKey, NULL);
    std::wstring desc = L"URL:" + schemeName + L" Protocol";
    RegSetValueExW(hKey, NULL, 0, REG_SZ,
                   (const BYTE*)desc.c_str(), (DWORD)((desc.size() + 1) * sizeof(wchar_t)));
    RegSetValueExW(hKey, L"URL Protocol", 0, REG_SZ, (const BYTE*)L"", sizeof(wchar_t));
    RegCloseKey(hKey);

    std::wstring cmdKeyPath = keyPath + L"\\shell\\open\\command";
    RegCreateKeyExW(HKEY_CURRENT_USER, cmdKeyPath.c_str(), 0, NULL,
                    0, KEY_WRITE, NULL, &hKey, NULL);
    std::wstring cmd = L"\"" + exePath + L"\" \"%1\"";
    RegSetValueExW(hKey, NULL, 0, REG_SZ,
                   (const BYTE*)cmd.c_str(), (DWORD)((cmd.size() + 1) * sizeof(wchar_t)));
    RegCloseKey(hKey);
}
```

> ⚠️ Without the protocol handler registration, clicking the Auth0 login link in the browser will **not** launch your app and authentication will time out with `USER_CANCELLED`.

#### 4. Update the runner (main.cpp)

Your app's `windows/runner/main.cpp` must be updated to handle single-instance enforcement, capture the callback URI from `argv[1]`, and forward it to the plugin via the `PLUGIN_STARTUP_URL` environment variable. Copy the reference implementation from the [example runner](example/windows/runner/main.cpp) and adapt it to your app. Update the callback prefix constant to match your chosen scheme (e.g. `L"myapp://callback"`). The key pieces are:

1. **Single-instance mutex** — prevents a second app instance when the OS launches your app for the protocol callback; instead, the URI is forwarded to the running instance.
2. **Named pipe server** — the running instance listens on a named pipe for URIs forwarded by the second launch.
3. **Startup URI capture** — on first launch, `argv[1]` (the callback URI) is written to `PLUGIN_STARTUP_URL` before Flutter initializes.

> 💡 See the [Windows configuration section](README.md#windows-configure-protocol-handler) in the README for a detailed walkthrough of each piece.

### Login

```dart
// Simple setup — appCustomURL only (recommended for most apps)
// Register your custom scheme (e.g. 'myapp://callback') in Allowed Callback URLs
// in the Auth0 dashboard.
final credentials = await auth0.windowsWebAuthentication().login(
  appCustomURL: 'myapp://callback',
);

// Intermediary HTTPS server
// Register 'https://your-app.example.com/callback' in Allowed Callback URLs.
// Auth0 redirects to the HTTPS URL; your server redirects onward to
// myapp://callback?code=...&state=... to activate the app.
final credentials = await auth0.windowsWebAuthentication().login(
  appCustomURL: 'myapp://callback',
  redirectUrl: 'https://your-app.example.com/callback',
);

// Access token -> credentials.accessToken
// User profile -> credentials.user
```

> ⚠️ Credentials are **not** automatically stored on Windows. Store and manage the returned `credentials` object yourself (e.g., using `shared_preferences` or secure storage).

### Logout

```dart
// Simple setup — appCustomURL only (recommended for most apps)
// Register your custom scheme (e.g. 'myapp://callback') in Allowed Logout URLs
// in the Auth0 dashboard.
await auth0.windowsWebAuthentication().logout(
  appCustomURL: 'myapp://callback',
);

// Intermediary HTTPS server
// Register 'https://your-app.example.com/logout' in Allowed Logout URLs.
// Auth0 redirects to the HTTPS URL; your server redirects onward to
// myapp://callback to re-activate the app.
await auth0.windowsWebAuthentication().logout(
  appCustomURL: 'myapp://callback',
  returnTo: 'https://your-app.example.com/logout',
);
```

[Go up ⤴](#examples)

## 📱 Credentials Manager

> This feature is mobile/macOS only; on web, the [SPA SDK](https://github.com/auth0/auth0-spa-js) used by auth0_flutter keeps its own cache. See [Handling Credentials on the Web](#-handling-credentials-on-the-web) for more details.

- [Check for stored credentials](#check-for-stored-credentials)
- [Retrieve stored credentials](#retrieve-stored-credentials)
- [Retrieve API credentials for a specific audience (MRRT)](#retrieve-api-credentials-for-a-specific-audience-mrrt)
- [Retrieve user profile](#retrieve-user-profile)
- [Custom implementations](#custom-implementations)
- [Local authentication](#local-authentication)
- [Credentials Manager configuration](#credentials-manager-configuration)
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

### Retrieve API credentials for a specific audience (MRRT)

If your app needs an access token for a **different API** than the one it logged in with, use `getApiCredentials()`. It exchanges the stored refresh token for an access token scoped to the requested `audience` using a [Multi-Resource Refresh Token (MRRT)](https://auth0.com/docs/secure/tokens/refresh-tokens/multi-resource-refresh-token). If valid API credentials for that audience are already cached, they are returned without a network call; otherwise a new token is fetched and cached for next time.

```dart
final apiCredentials = await auth0.credentialsManager.getApiCredentials(
  audience: 'https://my-api.example.com',
);

print('Access token: ${apiCredentials.accessToken}');
```

You can request specific scopes and pass additional options:

```dart
final apiCredentials = await auth0.credentialsManager.getApiCredentials(
  audience: 'https://my-api.example.com',
  scope: {'read:data', 'write:data'},
  minTtl: 60,
  parameters: {'key': 'value'},
  headers: {'key': 'value'},
);
```

To remove the cached API credentials for an audience – for example, on logout:

```dart
await auth0.credentialsManager.clearApiCredentials(
  audience: 'https://my-api.example.com',
  scope: 'read:data write:data',
);
```

> ⚠️ **Prerequisites:** Multi-Resource Refresh Tokens must be enabled on your tenant, and the `offline_access` scope must have been requested at login so that a refresh token is available for the exchange.
>
> 💡 Stored API credentials are keyed by **both** audience and scope on every platform, so pass the same `scope` to `clearApiCredentials()` that you used when fetching them. The native APIs do not consistently report whether a matching entry existed, so this method returns `void` rather than a success flag.

### Retrieve user profile

Fetch the user profile associated with the stored credentials. This method returns `null` if no credentials are present in storage.

```dart
final userProfile = await auth0.credentialsManager.user();

if (userProfile != null) {
  print('Email: ${userProfile.email}');
}
```

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

To enable this, pass a `LocalAuthentication` instance when you create your `Auth0` object.

```dart
const localAuthentication =
    LocalAuthentication(title: 'Please authenticate to continue');
final auth0 = Auth0('YOUR_AUTH0_DOMAIN', 'YOUR_AUTH0_CLIENT_ID',
    localAuthentication: localAuthentication);
final credentials = await auth0.credentialsManager.credentials();
```
> ⚠️ On Android, your app's `MainActivity.kt` file must extend `FlutterFragmentActivity` instead of `FlutterActivity` for biometric prompts to work.

Check the [API documentation](https://pub.dev/documentation/auth0_flutter_platform_interface/latest/auth0_flutter_platform_interface/LocalAuthentication-class.html) to learn more about the available `LocalAuthentication` properties.

> ⚠️ Enabling local authentication will not work if you're using a custom Credentials Manager implementation. In that case, you will need to build support for local authentication into your custom implementation.

### Credentials Manager configuration

You can set platform specific configuration on the CredentialManager while initialising it.
On iOS, this would mean configuring the `storeKey` of the Auth0.swift Credentials Manager, and the `accessGroup` and `accessibilty` of SimpleKeychain. If these are not set, the default values will be used.
On Android , you can configure the `sharedpreferences`  name used to store the credentials.

```dart
const configuration = CredentialsManagerConfiguration(
    androidConfiguration: AndroidCredentialsConfiguration("testSharedPreference"),
    iosConfiguration: IOSCredentialsConfiguration(
        storeKey: "iosStoreKey",
        accessGroup: "com.example.accessGroup",
        accessibility: Accessibility.afterFirstUnlock));

final auth0 = Auth0('YOUR_AUTH0_DOMAIN', 'YOUR_AUTH0_CLIENT_ID',
    credentialsManagerConfiguration: configuration);
final credentials = await auth0.credentialsManager.credentials();

```

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
if (e.isNoCredentialsFound) {
print("No credentials stored.");
} else if (e.isTokenRenewFailed) {
print("Failed to renew tokens.");
} else {
print(e);
}
}
```

#### Retryable errors

The `isRetryable` property on `CredentialsManagerException` indicates whether the error is transient and the operation can be retried. When `true`, the failure is likely due to a temporary condition such as a network outage. When `false`, the failure is permanent (e.g. an invalid refresh token) and retrying will not help — you should log the user out instead.

```dart
try {
  final credentials = await auth0.credentialsManager.credentials();
  // ...
} on CredentialsManagerException catch (e) {
  if (e.isRetryable) {
    // Transient error (e.g. network issue) — safe to retry
    print("Temporary error, retrying...");
  } else {
    // Permanent error — log the user out
    print("Credentials cannot be renewed: ${e.message}");
  }
}
```

> The `isRetryable` property is available on all exception types (`CredentialsManagerException`, `ApiException`, `WebAuthenticationException`) across Android and iOS/macOS. It returns `true` when the underlying failure is network-related, indicating the operation may succeed on retry.

### Native to Web SSO

Native to Web SSO allows authenticated users in your native mobile application to seamlessly transition to your web application without requiring them to log in again. This is achieved by exchanging a refresh token for a Session Transfer Token, which can then be used to establish a session in the web application.

The Session Transfer Token is:

- **Short-lived**: Expires after approximately 1 minute
- **Single-use**: Can only be used once to establish a web session
- **Secure**: Can be bound to the user's device through IP address or ASN

For detailed configuration and implementation guidance, see the [Auth0 Native to Web SSO documentation](https://auth0.com/docs/authenticate/single-sign-on/native-to-web/configure-implement-native-to-web).

#### Prerequisites

Before using Native to Web SSO:

1. **Enable Native to Web SSO on your Auth0 tenant** - This feature requires an Enterprise plan
2. [**Configure your native application**](https://auth0.com/docs/authenticate/single-sign-on/native-to-web/configure-implement-native-to-web#configure-native-applications)
3. **Request `offline_access` scope during login** to ensure a refresh token is issued

#### Get a Session Transfer Token

If you authenticated via **Web Auth** and stored credentials with the Credentials Manager, use `ssoCredentials()` — it handles token renewal automatically:

```dart
try {
  final ssoCredentials = await auth0.credentialsManager.ssoCredentials();

  print('Session Transfer Token: ${ssoCredentials.sessionTransferToken}');
  print('Token Type: ${ssoCredentials.tokenType}');
  print('Expires In: ${ssoCredentials.expiresIn} seconds');
} on CredentialsManagerException catch (e) {
  print('Failed to get SSO credentials: ${e.message}');
}
```

If you authenticated via the **Authentication API** (username/password login) and already hold a refresh token, you can exchange it directly using `auth0.api.ssoExchange()`:

```dart
try {
  final ssoCredentials = await auth0.api.ssoExchange(refreshToken: refreshToken);

  print('Session Transfer Token: ${ssoCredentials.sessionTransferToken}');
  print('Expires In: ${ssoCredentials.expiresIn} seconds');
} on ApiException catch (e) {
  print('SSO Exchange failed: ${e.code} - ${e.message}');
}
```

> ⚠️ If you are using the Credentials Manager to store the user's credentials, prefer `auth0.credentialsManager.ssoCredentials()` instead. It automatically handles refresh token rotation and is thread-safe, whereas `auth0.api.ssoExchange()` is not.

#### Sending the Session Transfer Token

There are two ways to send the Session Transfer Token to your web application:

**Option 1: As a Query Parameter**

Pass the token as a URL parameter when opening your web application:

```dart
final ssoCredentials = await auth0.credentialsManager.ssoCredentials();

final webAppUrl = Uri.parse('https://your-web-app.com/login').replace(
  queryParameters: {
    'session_transfer_token': ssoCredentials.sessionTransferToken,
  },
);

// Open using your preferred URL launcher or WebView package
await launchUrl(webAppUrl);
```

Your web application should then include the `session_transfer_token` in the `/authorize` request:

```js
// In your web application
const urlParams = new URLSearchParams(window.location.search);
const sessionTransferToken = urlParams.get('session_transfer_token');

if (sessionTransferToken) {
  const authorizeUrl =
    `https://YOUR_AUTH0_DOMAIN/authorize?` +
    `client_id=YOUR_WEB_CLIENT_ID&` +
    `redirect_uri=${encodeURIComponent('https://your-web-app.com/callback')}&` +
    `response_type=code&` +
    `scope=openid profile email&` +
    `session_transfer_token=${sessionTransferToken}`;

  window.location.href = authorizeUrl;
}
```

**Option 2: As a Cookie (WebView only)**

If your application uses a WebView to open your website, you can inject the Session Transfer Token as a cookie. The cookie will be automatically sent to Auth0's `/authorize` endpoint when your web application initiates authentication.

```dart
final ssoCredentials = await auth0.credentialsManager.ssoCredentials();

final cookie = 'auth0_session_transfer_token=${ssoCredentials.sessionTransferToken}; '
    'path=/; '
    'domain=YOUR_AUTH0_DOMAIN; ' // Or custom domain, if your website uses one
    'secure';

// Inject via your WebView controller (e.g. webview_flutter)
await webViewController.runJavaScript(
  "document.cookie = '$cookie';",
);

// Then navigate to your web application
await webViewController.loadRequest(
  Uri.parse('https://your-web-app.com'),
);
```

> **Important**: Make sure the cookie's domain matches the Auth0 domain your website is using, regardless of the domain your mobile app uses. Otherwise, the `/authorize` endpoint will not receive the cookie.
>
> - If your website uses the default Auth0 domain (like `example.us.auth0.com`), set the cookie's domain to this value
> - If your website uses a custom domain, use the custom domain value instead
>
> Cookie injection is platform-specific and may require additional WebView configuration.

> [!NOTE]
> This feature is designed for **iOS and Android** only. Since the purpose is to transition a native app session into a web session, calling `auth0.credentialsManager.ssoCredentials()` or `auth0.api.ssoExchange()` from any other platform is not supported.

[Go up ⤴](#examples)

## 🌐 Handling Credentials on the Web

> This section describes handling credentials for the web platform. For mobile/macOS, see [Credentials Manager](#-credentials-manager).

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

> This feature is mobile/macOS only; the [SPA SDK](https://github.com/auth0/auth0-spa-js) used by auth0_flutter does not include an API client.

- [Login with database connection](#login-with-database-connection)
- [Sign up with database connection](#sign-up-with-database-connection)
- [Log in with passkeys](#log-in-with-passkeys)
- [Sign up with passkeys](#sign-up-with-passkeys)
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

### Log in with passkeys

> This feature is available on **iOS 16.6+** and **Android 9+ (API 28)** only.

[Passkeys](https://auth0.com/docs/authenticate/database-connections/passkeys) let an existing user log in with a biometric or device PIN instead of a password, using the platform authenticator (Face ID / Touch ID on iOS, the Credential Manager on Android).

> ⚠️ Passkeys require additional configuration on both your Auth0 tenant and your app:
> - Set up a [custom domain](https://auth0.com/docs/customize/custom-domains) for your tenant. Passkeys will **not** work without one, since the relying-party domain must be a domain you own and can host the associated domain / Digital Asset Links file on.
> - Enable passkeys for your database connection and the **Passkey** grant type for your application. See [Configure passkeys](https://auth0.com/docs/authenticate/database-connections/passkeys/configure-passkeys).
> - Configure the [associated domain (iOS/macOS)](README.md#iosmacos-configure-the-associated-domain) and the equivalent [Digital Asset Links file](https://developer.android.com/identity/sign-in/credential-manager#add-support-dal) (Android) so the OS associates your app with the relying-party domain.

The SDK exposes **two** methods for passkey login — `passkeyLoginChallenge` and `passkeyCredentialExchange` — and leaves presenting the OS passkey UI to your app. The flow is:

1. Request a login challenge from Auth0 with `passkeyLoginChallenge`.
2. **In your app**, present the platform authenticator using that challenge and obtain a WebAuthn assertion. The SDK does **not** do this step — call the OS APIs directly (for example, [`ASAuthorizationController`](https://developer.apple.com/documentation/authenticationservices/asauthorizationcontroller) on iOS/macOS or [Credential Manager](https://developer.android.com/identity/sign-in/credential-manager) on Android, typically over your own platform channel), then map the result into a `PasskeyCredential`.
3. Exchange that credential for Auth0 tokens with `passkeyCredentialExchange`.

```dart
// 1. Request a login challenge from Auth0.
final challenge = await auth0.api.passkeyLoginChallenge(
    connection: 'Username-Password-Authentication');

// 2. Present the OS passkey UI in your app (not provided by the SDK) using
//    `challenge.authParamsPublicKey`, then build a PasskeyCredential from the
//    resulting WebAuthn assertion. All values are base64url-encoded.
final credential = PasskeyCredential(
    id: '<base64url credentialId>',
    rawId: '<base64url credentialId>',
    type: 'public-key',
    authenticatorAttachment: 'platform',
    response: PasskeyAuthenticatorResponse(
        clientDataJSON: '<base64url clientDataJSON>',
        authenticatorData: '<base64url authenticatorData>',
        signature: '<base64url signature>',
        userHandle: '<base64url userHandle>'));

// 3. Exchange the credential for Auth0 tokens.
final credentials = await auth0.api.passkeyCredentialExchange(
    challenge: challenge,
    credential: credential,
    connection: 'Username-Password-Authentication');

// Store the credentials afterward
final didStore =
    await auth0.credentialsManager.storeCredentials(credentials);
```

<details>
  <summary>Add an audience and scope values</summary>

```dart
final credentials = await auth0.api.passkeyCredentialExchange(
    challenge: challenge,
    credential: credential,
    connection: 'Username-Password-Authentication',
    audience: 'YOUR_AUTH0_API_IDENTIFIER',
    scopes: {'profile', 'email', 'offline_access', 'read:todos'});
```

</details>

### Sign up with passkeys

> This feature is available on **iOS 16.6+** and **Android 9+ (API 28)** only.

[Passkeys](https://auth0.com/docs/authenticate/database-connections/passkeys) let users register with a biometric or device PIN instead of a password, using the platform authenticator (Face ID / Touch ID on iOS, the Credential Manager on Android).

> ⚠️ Passkeys require additional configuration on both your Auth0 tenant and your app:
> - Set up a [custom domain](https://auth0.com/docs/customize/custom-domains) for your tenant. Passkeys will **not** work without one, since the relying-party domain must be a domain you own and can host the associated domain / Digital Asset Links file on.
> - Enable passkeys for your database connection and the **Passkey** grant type for your application. See [Configure passkeys](https://auth0.com/docs/authenticate/database-connections/passkeys/configure-passkeys).
> - Configure the [associated domain (iOS/macOS)](README.md#iosmacos-configure-the-associated-domain) and the equivalent [Digital Asset Links file](https://developer.android.com/identity/sign-in/credential-manager#add-support-dal) (Android) so the OS associates your app with the relying-party domain.

The SDK exposes **two** methods for passkey signup — `passkeySignupChallenge` and `passkeyCredentialExchange` — and leaves presenting the OS passkey UI to your app. The flow is:

1. Request a registration challenge from Auth0 with `passkeySignupChallenge`.
2. **In your app**, present the platform authenticator using that challenge and obtain a WebAuthn attestation. The SDK does **not** do this step — call the OS APIs directly (for example, [`ASAuthorizationController`](https://developer.apple.com/documentation/authenticationservices/asauthorizationcontroller) on iOS/macOS or [Credential Manager](https://developer.android.com/identity/sign-in/credential-manager) on Android, typically over your own platform channel), then map the result into a `PasskeyCredential`.
3. Exchange that credential for Auth0 tokens with `passkeyCredentialExchange` — the same method used for login.

You can identify the new user with any combination of `email`, `phoneNumber`, `username`, `name`, `givenName`, `familyName`, `nickname`, and `picture`, depending on how your connection is configured.

```dart
// 1. Request a registration challenge from Auth0. You can identify the new
//    user with any combination of email, phoneNumber, username, name,
//    givenName, familyName, nickname, and picture.
final challenge = await auth0.api.passkeySignupChallenge(
    email: 'jane.smith@example.com',
    name: 'Jane Smith',
    givenName: 'Jane',
    familyName: 'Smith',
    connection: 'Username-Password-Authentication');

// 2. Present the OS passkey-creation UI in your app (not provided by the SDK)
//    using `challenge.authParamsPublicKey`, then build a PasskeyCredential from
//    the resulting WebAuthn attestation. All values are base64url-encoded.
final credential = PasskeyCredential(
    id: '<base64url credentialId>',
    rawId: '<base64url credentialId>',
    type: 'public-key',
    authenticatorAttachment: 'platform',
    response: PasskeyAuthenticatorResponse(
        clientDataJSON: '<base64url clientDataJSON>',
        attestationObject: '<base64url attestationObject>'));

// 3. Exchange the credential for Auth0 tokens.
final credentials = await auth0.api.passkeyCredentialExchange(
    challenge: challenge,
    credential: credential,
    connection: 'Username-Password-Authentication');

// Store the credentials afterward
final didStore =
    await auth0.credentialsManager.storeCredentials(credentials);
```

<details>
  <summary>Add an audience and scope values</summary>

```dart
final credentials = await auth0.api.passkeyCredentialExchange(
    challenge: challenge,
    credential: credential,
    connection: 'Username-Password-Authentication',
    audience: 'YOUR_AUTH0_API_IDENTIFIER',
    scopes: {'profile', 'email', 'offline_access', 'read:todos'});
```

</details>

### Passwordless Login
Passwordless is a two-step authentication flow that requires the **Passwordless OTP** grant to be enabled for your Auth0 application. Check [our documentation](https://auth0.com/docs/get-started/applications/application-grant-types) for more information.

#### 1. Start the passwordless flow

Request a code to be sent to the user's email or phone number. For email scenarios, a link can be sent in place of the code.

```dart
await auth0.api.startPasswordlessWithEmail(
    email: "support@auth0.com", passwordlessType: PasswordlessType.code);
```
<details>
<summary>Using PhoneNumber</summary>

```dart
await auth0.api.startPasswordlessWithPhoneNumber(
    phoneNumber: "123456789", passwordlessType: PasswordlessType.code);
```
</details>

#### 2. Login with the received code

To complete the authentication, you must send back that code the user received along with the email or phone number used to start the flow.

```dart
final credentials = await auth0.api.loginWithEmailCode(
          email: "support@auth0.com", verificationCode: "000000");
```

<details>
<summary>Using SMS</summary>

```dart
final credentials = await auth0.api.loginWithSmsCode(
    phoneNumber: "123456789", verificationCode: "000000");
```
</details>

> [!NOTE]
> Sending additional parameters is supported only on iOS at the moment.

### Retrieve user information

Fetch the latest user information from the `/userinfo` endpoint.

This method will yield a `UserProfile` instance. Check the [API documentation](https://pub.dev/documentation/auth0_flutter_platform_interface/latest/auth0_flutter_platform_interface/UserProfile-class.html) to learn more about its available properties.

```dart
// Basic usage with Bearer token (default)
final userProfile = await auth0.api.userProfile(accessToken: accessToken);

// With explicit token type (useful for DPoP tokens)
final credentials = await auth0.credentialsManager.credentials();
final userProfile = await auth0.api.userProfile(
  accessToken: credentials.accessToken,
  tokenType: credentials.tokenType, // 'Bearer' or 'DPoP'
);
```

The `tokenType` parameter specifies the type of token being used:
- `'Bearer'` (default): Standard OAuth 2.0 bearer tokens
- `'DPoP'`: DPoP (Demonstrating Proof of Possession) tokens for enhanced security

> 💡 When using DPoP tokens, the SDK automatically handles proof generation. See the [DPoP documentation](DPOP.md) for more information.

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

### Custom Token Exchange

[Custom Token Exchange](https://auth0.com/docs/authenticate/custom-token-exchange) allows you to enable applications to exchange their existing tokens for Auth0 tokens when calling the /oauth/token endpoint. This is useful for advanced integration use cases, such as:
- Integrate an external identity provider 
- Migrate to Auth0

> **Note:** This feature is currently available in [Early Access](https://auth0.com/docs/troubleshoot/product-lifecycle/product-release-stages#early-access). Please reach out to Auth0 support to enable it for your tenant.

<details>
  <summary>Mobile (Android/iOS)</summary>

```dart
final credentials = await auth0.api.customTokenExchange(
  subjectToken: 'external-idp-token',
  subjectTokenType: 'urn:acme:legacy-token',
  audience: 'https://api.example.com', // Optional
  scopes: {'openid', 'profile', 'email'}, // Optional, defaults to {'openid', 'profile', 'email'}
  organization: 'org_abc123', // Optional
);
```

</details>

<details>
  <summary>Web</summary>

```dart
final credentials = await auth0Web.customTokenExchange(
  subjectToken: 'external-idp-token',
  subjectTokenType: 'urn:acme:legacy-token',
  audience: 'https://api.example.com', // Optional
  scopes: {'openid', 'profile', 'email'}, // Optional
  organizationId: 'org_abc123', // Optional
);
```

</details>

> 💡 For more information, see the [Custom Token Exchange documentation](https://auth0.com/docs/authenticate/custom-token-exchange) and [RFC 8693](https://tools.ietf.org/html/rfc8693).

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
  if (e.isRetryable) {
    // Transient error (e.g. network issue) — safe to retry
  } else {
    print(e);
  }
}
```

The `isRetryable` property indicates whether the error is transient (e.g. a network outage) and the operation can be retried. It returns `true` when `isNetworkError` is `true`.

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

> This example is mobile/macOS only; the [SPA SDK](https://github.com/auth0/auth0-spa-js) used by auth0_flutter does not include an API client.

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

## 📱 My Account API

The My Account API lets authenticated users manage their own multi-factor authentication (MFA) methods — enrolling, confirming, listing, updating, and deleting factors such as phone, email, TOTP, push notifications, and recovery codes. It is available on **mobile (Android/iOS) only**.

> 💡 The My Account API must be enabled for your tenant. If it is not yet available on your account, reach out to Auth0 support to get it enabled.

### Obtaining an access token for the My Account API

The My Account API requires an access token issued specifically for the `https://YOUR_DOMAIN/me/` audience, with the scopes for the operations you intend to perform.

The **recommended approach** is to log in **once** for your application with the `offline_access` scope (so a refresh token is stored), and then exchange that refresh token for a My Account–scoped access token — instead of launching a second interactive login. This is the same pattern the other Auth0 SDKs follow ([react-native-auth0](https://github.com/auth0/react-native-auth0/blob/master/EXAMPLES.md), [Auth0.swift](https://github.com/auth0/Auth0.swift/blob/master/EXAMPLES.md), and [Auth0.Android](https://github.com/auth0/Auth0.Android/blob/main/EXAMPLES.md)).

```dart
// 1. Log in once for your app, requesting offline_access to get a refresh token.
final credentials = await auth0.webAuthentication().login(
  scopes: {'openid', 'profile', 'email', 'offline_access'},
);
await auth0.credentialsManager.storeCredentials(credentials);

// 2. Exchange the stored refresh token for a token scoped to the My Account API,
//    by requesting the `https://YOUR_DOMAIN/me/` audience and the My Account scopes.
final myAccountCredentials = await auth0.credentialsManager.getApiCredentials(
  audience: 'https://YOUR_DOMAIN/me/',
  scope: {
    'read:me:authentication_methods',
    'create:me:authentication_methods',
    'update:me:authentication_methods',
    'delete:me:authentication_methods',
    'read:me:factors',
  },
);

// 3. Create the My Account client with the resulting access token.
final myAccount = auth0.myAccount(
  accessToken: myAccountCredentials.accessToken,
);
```

> 💡 `getApiCredentials` returns a **separate**, audience-scoped token via a [Multi-Resource Refresh Token (MRRT)](https://auth0.com/docs/secure/tokens/refresh-tokens/multi-resource-refresh-token) exchange; it does **not** replace the application credentials stored via `storeCredentials`. The token is cached per audience, so subsequent calls return the cached value until it expires.

> ⚠️ Exchanging the refresh token requires MRRT to be enabled for your tenant, and the application must have requested `offline_access` at login so that a refresh token is available.

### Listing and managing authentication methods

```dart
// List all enrolled MFA methods.
final methods = await myAccount.getAuthenticationMethods();

// Optionally filter by type.
final phones = await myAccount.getAuthenticationMethods(
  type: AuthenticationMethodType.phone,
);

// Retrieve a single method by id.
final method = await myAccount.getAuthenticationMethod(id: 'method_id');

// List the factors available for enrollment on the tenant.
final factors = await myAccount.getFactors();

// Update a method's display name and/or preferred phone channel.
await myAccount.updateAuthenticationMethod(
  id: 'method_id',
  name: 'My personal phone',
  preferredAuthenticationMethod: PhoneType.voice,
);

// Delete a method.
await myAccount.deleteAuthenticationMethod(id: 'method_id');
```

### Enrolling a factor with OTP (phone, email, TOTP)

Phone, email, and TOTP enrollments are completed by verifying a one-time password with `verifyOtp`. Pass the `factorType` of the factor you enrolled so the correct confirmation endpoint is used.

```dart
// Start phone enrollment (an OTP is sent via SMS).
final challenge = await myAccount.enrollPhone(
  phoneNumber: '+1234567890',
  type: PhoneType.sms,
);

// Confirm with the OTP the user received.
final method = await myAccount.verifyOtp(
  id: challenge.id,
  authSession: challenge.authSession,
  otp: '123456',
  factorType: 'phone', // 'phone' | 'email' | 'totp'
);
```

The same two-step flow applies to `enrollEmail` (`factorType: 'email'`) and `enrollTotp` (`factorType: 'totp'`).

### Enrolling a factor without OTP (push, recovery code)

Push notification and recovery code enrollments do not use an OTP — they are completed with `confirmEnrollment`.

```dart
// Start push enrollment.
final challenge = await myAccount.enrollPush();

// ...complete the out-of-band step (e.g. the user approves on their device), then:
final method = await myAccount.confirmEnrollment(
  id: challenge.id,
  authSession: challenge.authSession,
  factorType: 'push-notification', // 'push-notification' | 'recovery-code'
);
```

The same flow applies to `enrollRecoveryCode` (`factorType: 'recovery-code'`).

### Enrolling a passkey

A signed-in user can add a passkey as a new authentication method. Like passkey login and signup, this is a two-step flow and the SDK leaves presenting the OS passkey UI to your app:

1. Request an enrollment challenge with `enrollPasskeyChallenge`.
2. **In your app**, present the platform authenticator using `challenge.authParamsPublicKey` to create a passkey, and map the resulting WebAuthn attestation into a `PasskeyCredential`. The SDK does **not** do this step — call the OS APIs directly (for example, [`ASAuthorizationController`](https://developer.apple.com/documentation/authenticationservices/asauthorizationcontroller) on iOS/macOS or [Credential Manager](https://developer.android.com/identity/sign-in/credential-manager) on Android, typically over your own platform channel).
3. Submit the credential with `enrollPasskey` to complete the enrollment.

> ⚠️ Passkeys require a [custom domain](https://auth0.com/docs/customize/custom-domains) on your tenant and additional configuration. See [Sign up with passkeys](#sign-up-with-passkeys) for details.

The access token must include the `create:me:authentication_methods` scope.

```dart
// 1. Request an enrollment challenge.
final challenge = await myAccount.enrollPasskeyChallenge();

// 2. Present the OS passkey creation UI in your app (not provided by the SDK)
//    using `challenge.authParamsPublicKey`, then build a PasskeyCredential from
//    the resulting WebAuthn attestation.
final credential = PasskeyCredential(
  id: '...',
  rawId: '...',
  type: 'public-key',
  response: PasskeyAuthenticatorResponse(
    clientDataJSON: '...',
    attestationObject: '...',
  ),
);

// 3. Submit the credential to complete the enrollment.
final method = await myAccount.enrollPasskey(
  challenge: challenge,
  credential: credential,
);

print('Enrolled passkey: ${method.id} (${method.relyingPartyId})');
```

### Using DPoP

To secure My Account API requests with [DPoP](https://www.rfc-editor.org/rfc/rfc9449.html) (Demonstrating Proof-of-Possession) sender-constrained tokens, set `useDPoP` to `true` when creating the client. It defaults to `false`. The DPoP key pair is generated and stored securely on the device (Keychain on iOS, Keystore on Android).

```dart
final myAccount = auth0.myAccount(
  accessToken: myAccountCredentials.accessToken,
  useDPoP: true,
);
```

### Errors

My Account API calls throw a `MyAccountException` on failure.

```dart
try {
  await myAccount.getAuthenticationMethods();
} on MyAccountException catch (e) {
  print('${e.code}: ${e.message} (${e.statusCode})');
}
```

---

[Go up ⤴](#examples)

## 🌐📱 Multi-Factor Authentication (MFA)

> **Note:** This feature is currently available in [Early Access](https://auth0.com/docs/troubleshoot/product-lifecycle/product-release-stages#early-access). Please reach out to Auth0 support to enable it for your tenant.

The MFA API lets you complete a multi-factor authentication flow using an `mfa_token` — Auth0's [flexible/expanded grant support](https://auth0.com/docs/secure/multi-factor-authentication). It is available on **mobile (Android/iOS)** and **Web**; Windows is not supported.

Unlike the [My Account API](#-my-account-api) — which manages a signed-in user's authenticators — the MFA API is used **mid-login**, when a token request fails because MFA is required. You use the `mfa_token` from that failure to list, challenge, enroll, and verify a factor, and the successful verification returns the user's `Credentials`.

The mobile and web APIs are largely symmetric — `getAuthenticators`, `enrollTotp`/`enrollPhone`/`enrollEmail`/`enrollPush`, `challenge`, `verifyOtp`/`verifyOob`/`verifyRecoveryCode` — so the examples below apply to both. Two differences follow the underlying native SDKs and are noted inline: mobile `getAuthenticators` requires a non-empty `factorsAllowed` list (web takes none), and mobile `enrollPhone` is SMS-only while web also supports voice.

### Obtaining an `mfa_token`

When an authentication request requires a second factor, the SDK surfaces an `mfa_token` in the resulting error. Pass that token to `mfa(...)` to start the flow.

<details>
  <summary>Mobile (Android/iOS)</summary>

A failing token request (for example a database login or a credentials renewal) throws an `ApiException` whose `isMultifactorRequired` flag is `true` and which carries an `mfaToken`.

```dart
final auth0 = Auth0('YOUR_DOMAIN', 'YOUR_CLIENT_ID');

try {
  await auth0.api.login(
    usernameOrEmail: 'user@example.com',
    password: 'secret',
    connectionOrRealm: 'Username-Password-Authentication',
    scopes: {'openid', 'profile', 'email'},
  );
} on ApiException catch (e) {
  if (e.isMultifactorRequired && e.mfaToken != null) {
    final mfa = auth0.mfa(mfaToken: e.mfaToken!);

    // `mfaRequirements` (when present) tells you which factors the user can
    // be challenged with, and which they can newly enroll.
    final requirements = e.mfaRequirements;
    print('Can challenge: '
        '${requirements?.challenge.map((f) => f.type).toList()}');
    print('Can enroll: '
        '${requirements?.enroll.map((f) => f.type).toList()}');

    // ...drive the challenge or enrollment flow with `mfa` (see below).
  }
}
```

</details>

<details>
  <summary>Web</summary>

> **Note:** Web MFA is backed by the [auth0-spa-js](https://github.com/auth0/auth0-spa-js) programmatic MFA API and requires **auth0-spa-js v2.21.0 or later** loaded on your page. The MFA context is stored on the underlying client, so you must call `mfa(...)` on the **same `Auth0Web` instance** that triggered the error.

On the web, a failing token request throws a `WebException` with `code == 'MFA_REQUIRED'`. The `mfa_token` is carried in its `details` map under the `mfaToken` key.

```dart
final auth0Web = Auth0Web('YOUR_DOMAIN', 'YOUR_CLIENT_ID');

try {
  await auth0Web.credentials();
} on WebException catch (e) {
  final mfaToken = e.details['mfaToken'] as String?;
  if (e.code == 'MFA_REQUIRED' && mfaToken != null) {
    final mfa = auth0Web.mfa(mfaToken: mfaToken);

    // ...drive the challenge or enrollment flow with `mfa` (see below).
  }
}
```

</details>

### Listing authenticators and challenging a factor

If the user already has authenticators enrolled, list them and trigger a challenge on the one they choose. For out-of-band factors (SMS, Voice, Email, Push) the challenge delivers the code and returns an `oobCode`; for TOTP you verify the code directly without challenging.

```dart
// Mobile: `factorsAllowed` is required and must list at least one factor type
// (e.g. ['otp', 'oob']) — the native SDKs reject an empty list with
// `invalid_request`.
final authenticators =
    await mfa.getAuthenticators(factorsAllowed: ['otp', 'oob']);

// Web: `getAuthenticators()` takes no `factorsAllowed` argument — filtering is
// applied server-side from the mfa_token's requirements.
// final authenticators = await mfa.getAuthenticators();

final selected = authenticators.first;
final challenge = await mfa.challenge(authenticatorId: selected.id);

// `challenge.oobCode` is used to verify out-of-band factors (see below).
// When `challenge.bindingMethod == 'prompt'`, the user must also enter the
// code they received as the `bindingCode`.
```

### Enrolling a new factor

If the user has no suitable authenticator yet, enroll one. Each enrollment returns an `MfaEnrollmentChallenge`; which of its fields are populated depends on the factor.

```dart
// TOTP (authenticator app): render `barcodeUri` as a QR code (or show
// `totpSecret`), then verify with the OTP from the app.
final totp = await mfa.enrollTotp();
// totp.barcodeUri, totp.totpSecret, totp.recoveryCodes

// Phone: an OOB code is sent to the number via SMS.
// On mobile the native SDKs only support the SMS channel, so `enrollPhone`
// takes no `type`. On web you may pass `type: PhoneType.voice` for a voice call.
final phone = await mfa.enrollPhone(phoneNumber: '+1234567890');

// Email: an OOB code is sent to the address.
final email = await mfa.enrollEmail(email: 'user@example.com');

// Push (Auth0 Guardian): render `barcodeUri` for the user to scan.
final push = await mfa.enrollPush();
```

### Verifying and exchanging for credentials

Verifying completes the flow and exchanges the `mfa_token` for the user's `Credentials`. Pick the method that matches the factor:

Call the one method that matches the factor (each returns `Credentials`):

```dart
// TOTP — the code from the authenticator app.
final credentials = await mfa.verifyOtp(otp: '123456');
```

```dart
// Out-of-band (SMS, Voice, Email, Push) — the `oobCode` from the challenge
// (or enrollment). Provide `bindingCode` when the challenge's bindingMethod
// is `prompt` (the user enters the code they received).
final credentials = await mfa.verifyOob(
  oobCode: challenge.oobCode!,
  bindingCode: '123456',
);
```

```dart
// Recovery code — a one-time code the user saved during enrollment.
final credentials = await mfa.verifyRecoveryCode(recoveryCode: 'ABCD1234...');
```

On **mobile**, persist the returned credentials as usual:

```dart
await auth0.credentialsManager.storeCredentials(credentials);
```

On **Web**, auth0-spa-js manages the credential cache for you, so there is no separate store step — retrieve credentials afterward with `auth0Web.credentials()`.

### Errors

On **mobile**, MFA API calls throw an `MfaException` on failure. It exposes convenience getters for the common cases so you can branch without inspecting raw error codes.

```dart
try {
  final credentials = await mfa.verifyOtp(otp: '000000');
} on MfaException catch (e) {
  if (e.isMfaTokenExpired) {
    // The mfa_token is no longer valid — restart the login flow.
  } else if (e.isInvalidCode) {
    // The user entered a wrong/expired code — let them retry.
  } else if (e.isNetworkError) {
    // Transient — `e.isRetryable` is true.
  } else {
    print('${e.code}: ${e.message}');
  }
}
```

On **Web**, MFA API calls throw a `WebException`. Inspect its `code` and `message` to branch (for example, an expired `mfa_token` surfaces with code `expired_token`).

```dart
try {
  final credentials = await mfa.verifyOtp(otp: '000000');
} on WebException catch (e) {
  print('${e.code}: ${e.message}');
}
```

---

[Go up ⤴](#examples)
