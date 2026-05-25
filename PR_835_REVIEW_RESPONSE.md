# PR #835 Review Response: My Account API

## Summary

Consolidated review of both internal and external feedback. Categorized into: **Fixed**, **Acknowledged (Won't Fix)**, and **Deferred**.

---

## Fixed

### 1. Android: `totp_uri` mapped to wrong value

**File:** `auth0_flutter/android/src/main/kotlin/com/auth0/auth0_flutter/MyAccountExtensions.kt`

**Issue:** Both `totp_secret` and `totp_uri` were set to `challenge.manualInputCode`. The `totp_uri` should be `challenge.barcodeUri` (the `otpauth://` URI for QR code scanning).

**Fix applied:**
```kotlin
// Before
put("totp_uri", challenge.manualInputCode)

// After
put("totp_uri", challenge.barcodeUri)
```

This now matches the iOS implementation which correctly uses `authenticatorQRCodeURI` for `totp_uri`.

---

## Acknowledged - By Design (Won't Fix)

### 2. iOS `verifyOtp` uses `confirmPhoneEnrollment`

**Context:** The Auth0.swift SDK has separate confirm methods per factor type (`confirmPhoneEnrollment`, `confirmEmailEnrollment`, `confirmTOTPEnrollment`). However, the OTP confirmation logic is identical across these methods at the API level — they all POST an OTP code with an auth session to the same endpoint pattern. The `confirmPhoneEnrollment` method works generically for all OTP-based confirmations.

**Decision:** No change. The Android SDK exposes a single generic `verifyOtp(id, otp, authSession)` method which confirms this is the intended API design. If Auth0.swift separates the confirm calls in a future version in a breaking way, we'll update then.

### 3. `verifyOtp` returns `void` (discards `AuthenticationMethod` on Android)

**Context:** The Dart API is designed as `Future<void>` for `verifyOtp`. The caller already has the enrollment ID and can call `getAuthenticationMethod(id)` to get the confirmed method if needed. This matches the pattern where enrollment + verify is a two-step flow and the caller tracks the ID themselves.

**Decision:** No change. This is intentional API design — keeping `verifyOtp` as a void confirmation action rather than a data-fetching operation.

### 4. iOS `AuthenticationMethod.asDictionary()` — `email`, `totp_secret`, `totp_uri` are nil

**Context:** The Auth0.swift `AuthenticationMethod` struct is a flat type — it does not have subclasses for email/TOTP like Android's polymorphic `EmailAuthenticationMethod`/`TotpAuthenticationMethod`. The Swift SDK's base `AuthenticationMethod` only exposes `phoneNumber` and `name` as type-specific fields. Email and TOTP details are only available during enrollment (via `EnrollmentChallenge` types, which ARE correctly mapped).

**Decision:** No change. This is a limitation of the Auth0.swift SDK's type model. The relevant fields are returned during enrollment when they matter. For `getAuthenticationMethods()`, the `type` field identifies the method type and `id` can be used for management operations.

### 5. `Factor` model uses `name` + `enabled` instead of `type` + `usage`

**Context:** The native SDK `Factor` has `type` (String) and `usage` (array of strings like `["primary", "secondary"]`). The Flutter model simplifies this to `name` (mapped from `type`) and `enabled` (hardcoded `true`). The rationale: if a factor is returned by the API, it IS enabled — disabled factors are not returned. The `usage` array is not actionable for self-service MFA management.

**Decision:** No change for v1. The simplified model serves the primary use case (showing available factors for enrollment). If users need `usage` data, we can add it in a minor version bump without breaking changes.

### 6. iOS `isNetworkError` hardcoded to `false`

**Context:** The Auth0.swift `MyAccountError` type does not expose a network error flag directly. The error is an API response error (with status code and error code). Network-level failures (no connectivity, timeout) would surface as a different error type entirely and would not reach this code path.

**Decision:** No change. The `isNetworkError: false` is correct for API errors. True network errors are handled at the URLSession/connectivity layer.

### 7. iOS `userAgent` not applied to client

**Context:** The Auth0.swift `myAccount()` factory creates a client with built-in telemetry. The `using()` pattern for custom user agents is not available on `MyAccount` in the current Auth0.swift version. The telemetry parameter is accepted in the handler for future use when the Swift SDK supports it.

**Decision:** No change now. Will be wired up when Auth0.swift adds telemetry customization to MyAccount.

---

## Deferred (Future Enhancement)

### 8. Missing `updateAuthenticationMethod`

The native SDKs support updating an authentication method's name or preferred delivery mechanism. This is a valid feature gap but out of scope for the initial release.

**Tracked for:** v2 enhancement

### 9. Missing passkey enrollment

Both native SDKs support passkey enrollment via WebAuthn/FIDO2. This requires significant platform-specific work (platform credential APIs, attestation handling) and is deferred.

**Tracked for:** Future release (depends on Flutter passkey ecosystem maturity)

### 10. Per-factor confirmation methods (push/recovery code without OTP)

Push notification and recovery code enrollments don't require OTP verification. The current `verifyOtp` method won't work for these. However, the enrollment responses for push and recovery code return all needed data immediately — push enrollment auto-confirms, and recovery code enrollment returns the code directly.

**Decision:** Deferred. If auto-confirmation doesn't cover these cases in practice, we'll add `confirmPushEnrollment` and `confirmRecoveryCodeEnrollment` methods.

### 11. Missing `confirmed` field on Dart `AuthenticationMethod`

The Android side serializes `confirmed` but the Dart model doesn't include it. This is useful for showing enrollment status in UI.

**Tracked for:** Next minor version (additive, non-breaking)

### 12. Dart-level unit tests

No Dart tests for `MethodChannelAuth0FlutterMyAccount`, `MyAccountApi`, or model parsing. Android and iOS have native tests. Dart tests would improve confidence in serialization layer.

**Tracked for:** Follow-up PR

### 13. Android empty string fallback for missing `accessToken`

```kotlin
val accessToken = request.data["accessToken"] as? String ?: ""
```

Should fail fast instead of making API calls with empty bearer token. Low risk since the Dart layer always provides the token, but defensive programming suggests erroring early.

**Tracked for:** Follow-up hardening PR

---

## Changes Made in This Response

| # | File | Change |
|---|------|--------|
| 1 | `MyAccountExtensions.kt:52` | Fixed `totp_uri` to use `challenge.barcodeUri` instead of `challenge.manualInputCode` |

---
