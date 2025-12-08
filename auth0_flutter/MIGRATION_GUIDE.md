# Migration Guide

## Native SDK Version Updates

This release includes updates to the underlying native Auth0 SDKs to support new features including DPoP (Demonstrating Proof of Possession). These updates are **transparent** to your application code - no code changes are required unless you want to opt into new features like DPoP.

### Updated SDK Versions

| Platform | Previous Version | New Version | Changes |
|----------|-----------------|-------------|---------|
| **Android** | Auth0.Android 2.11.0 | Auth0.Android 3.11.0 | DPoP support, **biometric auth requires FlutterFragmentActivity** |
| **iOS/macOS** | Auth0.swift 2.10.0 | Auth0.swift 2.14.0 | DPoP support, improved APIs |
| **Web** | auth0-spa-js 2.0 | auth0-spa-js 2.9.0 | DPoP support, bug fixes |

### What's New

#### DPoP (Demonstrating Proof of Possession) Support
All platforms now support DPoP, an optional OAuth 2.0 security extension that cryptographically binds access tokens to your client, preventing token theft and replay attacks.

**This is an opt-in feature** - your existing authentication flows will continue to work without any changes.

To enable DPoP:
```dart
// Mobile
final credentials = await auth0.webAuthentication().login(useDPoP: true);

// Web
final auth0Web = Auth0Web('DOMAIN', 'CLIENT_ID', useDPoP: true);
```

For complete DPoP documentation, see the [README](README.md#using-dpop-demonstrating-proof-of-possession).

### Do I Need to Make Changes?

**Most users do not need to make changes.** However, there is one breaking change that affects users of biometric authentication on Android.

#### ⚠️ Breaking Change: Android Biometric Authentication

**If you use biometric authentication on Android**, your `MainActivity.kt` must now extend `FlutterFragmentActivity` instead of `FlutterActivity`.

This requirement comes from Auth0.Android SDK 3.x, which changed its biometric authentication implementation.

**Who is affected:**
- ✅ Users who call `credentialsManager.credentials()` with `localAuthentication` parameter
- ✅ Only on Android platform
- ✅ Only if your `MainActivity.kt` currently extends `FlutterActivity`

**Required change:**

```kotlin
// Before (will cause error)
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
}

// After (required for biometric auth)
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity: FlutterFragmentActivity() {
}
```

**If you don't use biometric authentication,** no changes are needed.

#### Optional New Features

You only need to make changes if you want to:
- ✅ Enable DPoP for enhanced security (optional)
- ✅ Use new DPoP API methods: `getDPoPHeaders()` and `clearDPoPKey()` (optional)

### Java Version Requirement (Android)

**Java 8** remains the minimum requirement for Android builds. The SDK continues to use:
- `sourceCompatibility JavaVersion.VERSION_1_8`
- `targetCompatibility JavaVersion.VERSION_1_8`

No changes to your Java setup are needed.

## What's New

This version includes support for **DPoP (Demonstrating Proof of Possession)**, an optional OAuth 2.0 security feature that cryptographically binds access tokens to a specific client. DPoP is completely opt-in and your existing authentication flows will continue to work without any modifications.

For detailed DPoP usage instructions, see the [README DPoP section](README.md#using-dpop-demonstrating-proof-of-possession).
