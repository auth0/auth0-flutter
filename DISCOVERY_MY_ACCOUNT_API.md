# My Account API - Flutter SDK Discovery Document

**Date:** 2026-05-12  
**Status:** Discovery / Pre-Implementation  
**Author:** Utkrisht Sahu  

---

## 1. Overview

The My Account API (`/me/v1/`) enables end-users to self-manage their authentication methods (MFA factors) without requiring Management API tokens or admin intervention. This document outlines the discovery findings and proposed approach for implementing My Account API support in the auth0-flutter SDK.

---

## 2. What is the My Account API?

The My Account API allows authenticated users to:

- **List** their enrolled authentication methods
- **Get** details of a specific authentication method
- **Update** an authentication method (e.g., change phone preferences)
- **Delete** an authentication method
- **Enroll** new authentication methods (phone, email, TOTP, push notifications, passkeys, recovery codes)
- **Verify** enrollments via OTP
- **View** enrollable factors available for the tenant

### Authentication

- Uses OAuth 2.0 access tokens with audience: `https://{domain}/me/`
- Requires granular scopes:
  - `read:me:authentication_methods`
  - `create:me:authentication_methods`
  - `update:me:authentication_methods`
  - `delete:me:authentication_methods`
  - `read:me:factors`

### Security

- Enforces step-up authentication (2FA within 15 minutes by default)
- Rate limited at 25 requests/second per tenant
- Machine-to-machine access is prohibited

---

## 3. Existing Native SDK Implementations

### 3.1 Android (`Auth0.Android`)

**Class:** `MyAccountAPIClient`

| Method | Description |
|--------|-------------|
| `getAuthenticationMethods()` | List all enrolled methods |
| `getAuthenticationMethodById(id)` | Get specific method |
| `updateAuthenticationMethodById(id, ...)` | Update method name/preferences |
| `deleteAuthenticationMethod(id)` | Delete a method |
| `enrollPhone(phoneNumber, type)` | Enroll phone (SMS/Voice) |
| `enrollEmail(emailAddress)` | Enroll email |
| `enrollTotp()` | Enroll authenticator app |
| `enrollPushNotification()` | Enroll push notifications |
| `enrollRecoveryCode()` | Generate recovery codes |
| `passkeyEnrollmentChallenge(...)` | Get passkey challenge |
| `enroll(passkey)` | Complete passkey enrollment |
| `verifyOtp(id, authSession, otp)` | Verify OTP for enrollment |
| `verify(id, authSession)` | Confirm non-OTP enrollment |
| `getFactors()` | List enrollable factors |

- Returns `Request<T, MyAccountException>` objects
- Access token provided at client construction
- `MyAccountException` includes: `code`, `statusCode`, `description`, `validationErrors`

### 3.2 Swift (`Auth0.swift`)

**Classes:** `Auth0MyAccount` + `Auth0MyAccountAuthenticationMethods`

| Method | Description |
|--------|-------------|
| `getAuthenticationMethods()` | List all enrolled methods |
| `getAuthenticationMethod(by: id)` | Get specific method |
| `deleteAuthenticationMethod(by: id)` | Delete a method |
| `enrollPhone(phoneNumber:, preferredAuthenticationMethod:)` | Enroll phone |
| `confirmPhoneEnrollment(id:, authSession:, otpCode:)` | Confirm phone |
| `enrollEmail(emailAddress:)` | Enroll email |
| `confirmEmailEnrollment(id:, authSession:, otpCode:)` | Confirm email |
| `enrollTOTP()` | Enroll authenticator app |
| `confirmTOTPEnrollment(id:, authSession:, otpCode:)` | Confirm TOTP |
| `enrollPushNotification()` | Enroll push |
| `confirmPushNotificationEnrollment(id:, authSession:)` | Confirm push |
| `enrollRecoveryCode()` | Generate recovery codes |
| `confirmRecoveryCodeEnrollment(id:, authSession:)` | Confirm recovery |
| `passkeyEnrollmentChallenge(...)` | Get passkey challenge |
| `enroll(passkey:, challenge:)` | Complete passkey enrollment |
| `getFactors()` | List enrollable factors |

- Protocol-based architecture
- Factory: `Auth0.myAccount(token: accessToken, domain: "...")`
- URL pattern: `{domain}/me/v1/authentication-methods`
- Two-step enrollment: challenge then confirm
- `MyAccountError` includes: `code`, `statusCode`, `title`, `detail`, `validationErrors`

### 3.3 SPA (`auth0-spa-js`)

**Does NOT implement My Account Authentication Methods.**

The SPA SDK only implements Connected Accounts (Token Vault), which is a separate feature for linking external provider tokens — not related to My Account MFA management.

---

## 4. Platform Support Matrix

| Feature | Android | iOS/macOS (Swift) | Web (SPA) | Flutter (Proposed) |
|---------|:-------:|:-----------------:|:---------:|:------------------:|
| List authentication methods | ✅ | ✅ | ❌ | ✅ Mobile only |
| Get authentication method | ✅ | ✅ | ❌ | ✅ Mobile only |
| Update authentication method | ✅ | ❌ | ❌ | ✅ Android only |
| Delete authentication method | ✅ | ✅ | ❌ | ✅ Mobile only |
| Enroll phone (SMS/Voice) | ✅ | ✅ | ❌ | ✅ Mobile only |
| Enroll email | ✅ | ✅ | ❌ | ✅ Mobile only |
| Enroll TOTP | ✅ | ✅ | ❌ | ✅ Mobile only |
| Enroll push notifications | ✅ | ✅ | ❌ | ✅ Mobile only |
| Enroll recovery codes | ✅ | ✅ | ❌ | ✅ Mobile only |
| Passkey enrollment | ✅ | ✅ (iOS 16.6+) | ❌ | ✅ Mobile only |
| Verify OTP | ✅ | ✅ | ❌ | ✅ Mobile only |
| Get factors | ✅ | ✅ | ❌ | ✅ Mobile only |
| **Web support** | — | — | ❌ | **❌ Not supported** |

---

## 5. Flutter Implementation Strategy

### 5.1 Architecture

Flutter will act as a **bridge layer** — delegating to the native SDKs (Auth0.Android and Auth0.swift) via method channels. No direct HTTP calls to the My Account API.

```
┌─────────────────────────────────────────────────────┐
│                  User Application                     │
├─────────────────────────────────────────────────────┤
│           auth0_flutter (Public Dart API)             │
│                MyAccountApi class                     │
├─────────────────────────────────────────────────────┤
│     auth0_flutter_platform_interface                  │
│   Auth0FlutterMyAccountPlatform (abstract)           │
│   MethodChannelAuth0FlutterMyAccount                 │
├─────────────────────────────────────────────────────┤
│         Method Channel Bridge                        │
├──────────────────────┬──────────────────────────────┤
│   Android (Kotlin)   │       iOS/macOS (Swift)       │
│  MyAccountAPIClient  │       Auth0MyAccount          │
│  (Auth0.Android SDK) │       (Auth0.swift SDK)       │
└──────────────────────┴──────────────────────────────┘
```

### 5.2 Public API Design

```dart
// Access My Account API
final myAccount = auth0.myAccount(accessToken: token);

// List methods
final methods = await myAccount.getAuthenticationMethods();

// Get specific method
final method = await myAccount.getAuthenticationMethod(id: 'auth_method_id');

// Delete method
await myAccount.deleteAuthenticationMethod(id: 'auth_method_id');

// Enroll phone
final challenge = await myAccount.enrollPhone(
  phoneNumber: '+1234567890',
  type: PhoneType.sms,
);

// Verify enrollment
await myAccount.verifyOtp(
  id: challenge.id,
  authSession: challenge.authSession,
  otp: '123456',
);

// Get available factors
final factors = await myAccount.getFactors();
```

### 5.3 Key Models

- `AuthenticationMethod` — represents an enrolled MFA method
- `Factor` — represents an enrollable factor type
- `EnrollmentChallenge` — returned from enrollment methods (contains `id`, `authSession`)
- `MyAccountException` — error with `code`, `statusCode`, `description`, `validationErrors`
- `PhoneType` — enum: `sms`, `voice`

### 5.4 Web Platform

**Not supported.** The SPA SDK does not implement My Account Authentication Methods. Calling My Account methods on web will throw `UnsupportedError`.

---

## 6. Phased Rollout Plan

### Phase 1: Core Read/Delete Operations
- `getAuthenticationMethods()`
- `getAuthenticationMethod(id:)`
- `deleteAuthenticationMethod(id:)`
- `getFactors()`
- `MyAccountException` error handling
- Platform interface + method channel setup

### Phase 2: Enrollments + Verification
- `enrollPhone(phoneNumber:, type:)`
- `enrollEmail(emailAddress:)`
- `enrollTotp()`
- `enrollPushNotification()`
- `enrollRecoveryCode()`
- `verifyOtp(id:, authSession:, otp:)`
- `verify(id:, authSession:)`

### Phase 3: Passkey Enrollment
- `passkeyEnrollmentChallenge(userIdentityId:, connection:)`
- `enrollPasskey(passkey:, challenge:)`
- Platform version guards (iOS 16.6+, Android API level checks)

---

## 7. Open Questions

1. Do we need `updateAuthenticationMethod()` on iOS? (Swift SDK doesn't expose it, Android does)
2. Should we throw `UnsupportedError` on web, or silently degrade?
3. What minimum iOS/Android versions should we target for passkey support?
4. Should the access token be passed per-call or at `MyAccountApi` construction time?

---

## 8. References

- [My Account API Documentation](https://auth0.com/docs/manage-users/my-account-api)
- [Auth0.Android SDK](https://github.com/auth0/Auth0.Android)
- [Auth0.swift SDK](https://github.com/auth0/Auth0.swift)
- [auth0-spa-js SDK](https://github.com/auth0/auth0-spa-js)
