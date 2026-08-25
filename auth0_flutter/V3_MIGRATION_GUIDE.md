# Migration Guide from auth0_flutter v2 to v3

`auth0_flutter` v3 upgrades the wrapped native SDKs to their next major versions
— **Auth0.Android v4** on Android and **Auth0.swift v3** on iOS/macOS. Those
upgrades raise the minimum platform requirements and change some native
behavior that surfaces through the Dart API.

> **Note**
> This is a living document. It currently covers the **Android** track changes.
> The remaining cross-platform Dart API renames (for example
> `expiresIn` → `expiresAt`, `clearSession` → `logout`, `UserInfo` →
> `UserProfile`) land in later v3 PRs and will be documented here as they merge.

## Table of Contents

- [Requirements Changes](#requirements-changes)
- [Behavior Changes](#behavior-changes)
  - [`credentialsManager.clearCredentials` now clears all stored data (Android)](#credentialsmanagerclearcredentials-now-clears-all-stored-data-android)
  - [New `credentialsManager.clearAll()` for a full wipe](#new-credentialsmanagerclearall-for-a-full-wipe)
  - [`api.multifactorChallenge` requires `authenticatorId` (Android)](#apimultifactorchallenge-requires-authenticatorid-android)
  - [Web Auth `useEphemeralSession` is now honored on Android](#web-auth-useephemeralsession-is-now-honored-on-android)
  - [Android Web Auth recovers login results across process death](#android-web-auth-recovers-login-results-across-process-death)
- [Getting Help](#getting-help)

## Requirements Changes

Because the underlying native SDKs raised their floors, `auth0_flutter` v3
raises the Android minimums:

| Requirement | v2 | v3 |
| --- | --- | --- |
| Android `minSdkVersion` | 21 | **26** (Android 8.0) |
| Android compile/target SDK | 34 | **36** |
| JDK (to build the Android module) | 8 | **17** |
| Kotlin | 1.9.x | **2.0.21** |
| Android Gradle Plugin | 8.4.x | **8.10.1** |
| Gradle | 8.7 | **8.11.1** |

**Migration:** if your app targets an Android `minSdkVersion` below 26, raise it
to at least 26 in your app's `android/app/build.gradle`. Ensure your build
environment uses JDK 17 (for example, set it in Android Studio under
*Settings → Build, Execution, Deployment → Build Tools → Gradle → Gradle JDK*,
or via `org.gradle.java.home`).

There are **no source changes required** to your Dart code for these
requirement bumps.

## Behavior Changes

### `credentialsManager.clearCredentials` now clears all stored data (Android)

**Change:** In Auth0.Android v4, `clearCredentials()` performs a full wipe of
the underlying storage (`Storage.removeAll()`) rather than removing only the
individual credential entries it wrote.

**Impact:** If your app stored unrelated values in the same
`SharedPreferences` instance that the credentials manager uses (for example, by
supplying a custom `sharedPreferencesName` via
`CredentialsManagerConfiguration` and reusing it elsewhere), calling
`clearCredentials` now removes those values too.

**Migration:** Do not share the credentials manager's storage with other data.
Keep any app data you need to persist independently of Auth0 credentials in a
separate store. The Dart API is unchanged:

```dart
// Same call as v2 — behavior on Android is now a full wipe of the store.
await credentialsManager.clearCredentials();
```

This affects Android only. iOS/macOS behavior is unchanged.

### New `credentialsManager.clearAll()` for a full wipe

**Change (additive):** v3 adds `credentialsManager.clearAll()`, which removes all
stored credentials and cached API credentials **and** the underlying encryption
keys — on Android the crypto key pair and the DPoP key, on iOS/macOS every entry
in the credentials store plus the DPoP key pair. It maps to Auth0.Android v4's
`clearAll()` and Auth0.swift v3's `clearAll()`.

**Impact:** This is a new, optional method, so existing code is unaffected. Use
`clearCredentials()` to remove only the stored credential entries, or
`clearAll()` when you also want to drop the encryption keys (for example a full
sign-out/reset):

```dart
await auth0.credentialsManager.clearAll();
```

Because `clearAll()` deletes every entry in the underlying store, avoid sharing
that store (a custom `sharedPreferencesName` on Android, or `storeKey` /
`accessGroup` on iOS/macOS) with unrelated app data.

### `api.multifactorChallenge` requires `authenticatorId` (Android)

**Change:** Auth0.Android v4 removed the inline MFA methods from the
authentication client and routes MFA through a dedicated MFA client whose
`challenge` operation accepts only an `authenticatorId` — there is no
challenge-type filtering.

**Impact:** On Android, a `multifactorChallenge` call must now include
`authenticatorId`. A call that supplies only `types` and omits
`authenticatorId` — which was accepted in v2 — now fails on Android. Any `types`
value passed is ignored on Android.

> **Note**
> The Dart signature of `multifactorChallenge` is unchanged in this release
> (`types` and `authenticatorId` remain optional parameters), so this is a
> runtime behavior change on Android rather than a compile-time break. iOS
> already requires `authenticatorId`. A later v3 PR realigns the shared Dart
> API to make `authenticatorId` required and remove `types` across platforms.

**Migration:** Always pass `authenticatorId` when calling
`multifactorChallenge`, and stop relying on `types`:

```dart
// ❌ v2 — worked on Android, relied on challenge-type filtering
final challenge = await auth0.api.multifactorChallenge(
  mfaToken: mfaToken,
  types: [ChallengeType.otp, ChallengeType.oob],
);

// ✅ v3 — pass the authenticator to challenge
final challenge = await auth0.api.multifactorChallenge(
  mfaToken: mfaToken,
  authenticatorId: authenticatorId,
);
```

If you support one-time passwords and don't need to select a specific factor,
you can skip the challenge request and call `api.loginWithOtp` directly.

### Web Auth `useEphemeralSession` is now honored on Android

**Change:** In v2 the Web Auth `useEphemeralSession` login option had no effect
on Android (it was accepted but ignored, and documented as iOS/macOS only). In
v3, Android honors it via Auth0.Android v4's ephemeral browsing, matching
iOS/macOS.

**Impact:** If your Android app already passed `useEphemeralSession: true`
expecting it to be ignored, the login now runs in a private/ephemeral browser
session: no session is shared with or persisted in the system browser, so the
user is not silently signed in from an existing browser session.

**Migration:** No code change is required. Review your use of
`useEphemeralSession` on Android if you relied on the previous no-op behavior:

```dart
// v3: on Android this now starts an ephemeral browser session (as on iOS/macOS).
await auth0.webAuthentication().login(useEphemeralSession: true);
```

> **Note**
> Ephemeral sessions depend on the device browser supporting them. If the
> browser that handles the login does not support ephemeral browsing, Android
> falls back to a normal Custom Tabs login and the session is not ephemeral.

### Android Web Auth recovers login results across process death

**Change:** Android Web Auth now registers its login callback against the
activity lifecycle (via Auth0.Android v4's `WebAuthProvider.registerCallbacks`)
instead of the deprecated global callback. As a result, a login result is
delivered even if the activity is recreated across a configuration change or the
process is killed and restarted while the browser is in the foreground.

**Impact:** This is an internal improvement. The Dart API is unchanged and no
code change is required.

## Getting Help

If you encounter issues migrating, please open an issue on the
[auth0-flutter repository](https://github.com/auth0/auth0-flutter/issues) with
details of the API you're migrating and the platform affected.
