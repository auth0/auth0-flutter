# Migration Guide: v1.x to v2.0.0

## Summary

**auth0_flutter v2.0.0** includes updates to the underlying native Auth0 SDKs to support new features including **DPoP (Demonstrating Proof of Possession)**. 

**Do I need to make changes?**
- ⚠️ **YES** - If you use biometric authentication on Android, you **MUST** update your `MainActivity` (see below)
- ✅ **NO** - If you don't use biometric authentication, your code will work without changes
- 🆕 **OPTIONAL** - You can optionally enable new features like DPoP

## Breaking Changes

### ⚠️ Android: MainActivity Must Extend FlutterFragmentActivity

**If you use biometric authentication on Android**, you must change your `MainActivity.kt` to extend `FlutterFragmentActivity` instead of `FlutterActivity`.

**Who is affected:**
- ✅ Users who call `credentialsManager.credentials()` with the `localAuthentication` parameter on Android
- ✅ Only if your `MainActivity.kt` currently extends `FlutterActivity`

**Required change:**

```kotlin
// ❌ Before (will cause crash with biometric auth)
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
}

// ✅ After (required for biometric auth in v2.0.0)
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity: FlutterFragmentActivity() {
}
```

**Why this change?**
This requirement comes from Auth0.Android SDK 3.x, which changed its biometric authentication implementation to use Fragments. The Flutter plugin requires `FlutterFragmentActivity` to properly display biometric prompts.

**If you don't use biometric authentication,** no changes are needed, but switching to `FlutterFragmentActivity` is recommended for future compatibility.

## Native SDK Version Updates

This release updates the underlying native Auth0 SDKs to support new features including DPoP (Demonstrating Proof of Possession).

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

## Optional New Features

You can optionally adopt these new features:
- ✅ Enable DPoP for enhanced security (optional)
- ✅ Use new DPoP API methods: `getDPoPHeaders()` and `clearDPoPKey()` (optional)

## Requirements

### Flutter & Dart Versions
- **Flutter SDK:** 3.24.0 or higher
- **Dart SDK:** 3.5.0 or higher

### Platform Versions
| Platform | Minimum Version |
|----------|----------------|
| **Android** | API 21+ (Android 5.0) |
| **iOS** | iOS 14+ |
| **macOS** | macOS 11+ |

### Android Build Requirements
**Java 8** remains the minimum requirement for Android builds. No changes to your Java setup are needed.
- `sourceCompatibility JavaVersion.VERSION_1_8`
- `targetCompatibility JavaVersion.VERSION_1_8`

## Troubleshooting

### Android: App crashes when using biometric authentication

**Error:** App crashes or shows fragment-related errors when calling `credentialsManager.credentials()` with biometric authentication.

**Solution:** Make sure your `MainActivity.kt` extends `FlutterFragmentActivity`:

```kotlin
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity: FlutterFragmentActivity() {
}
```

### DPoP is not working

**Issue:** DPoP tokens are not being generated or validated.

**Check:**
1. Ensure you've enabled DPoP in your login call: `auth0.webAuthentication().login(useDPoP: true)`
2. Verify your Auth0 tenant supports DPoP
3. Check that you're using the credentials returned from the DPoP-enabled login

For detailed DPoP usage instructions, see the [README DPoP section](README.md#using-dpop-demonstrating-proof-of-possession).

## What's New in v2.0.0

### DPoP (Demonstrating Proof of Possession) Support
All platforms now support DPoP, an optional OAuth 2.0 security feature that cryptographically binds access tokens to a specific client, preventing token theft and replay attacks.

**Key Features:**
- 🔒 Enhanced token security with cryptographic binding
- 🌐 Cross-platform support (Android, iOS, macOS, Web)
- 🔧 Easy opt-in with simple API
- 📱 New DPoP management methods: `getDPoPHeaders()` and `clearDPoPKey()`

**Platform Updates:**
- **Android:** Auth0.Android 2.11.0 → 3.11.0
- **iOS/macOS:** Auth0.swift 2.10.0 → 2.14.0  
- **Web:** auth0-spa-js 2.0 → 2.9.0

DPoP is completely opt-in and your existing authentication flows will continue to work without any modifications.

## Need Help?

- 📚 [README](README.md) - Full documentation
- 💬 [Discussions](https://github.com/auth0/auth0-flutter/discussions) - Ask questions
- 🐛 [Issues](https://github.com/auth0/auth0-flutter/issues) - Report bugs
