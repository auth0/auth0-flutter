# Testing the My Account API Implementation

## Prerequisites

### Auth0 Tenant Configuration

1. **Enable MFA** in your Auth0 tenant:
   - Dashboard → Security → Multi-factor Auth
   - Enable the factors you want to test (SMS, Email, OTP, Push)

2. **Create/Configure an Application**:
   - Dashboard → Applications → Your App
   - Note your `domain` and `clientId`

3. **Create a Custom API** (if not exists):
   - Dashboard → Applications → APIs
   - Create API with identifier: `https://{your-domain}/me/`
   - This is the My Account API audience

4. **Grant Scopes to Your Application**:
   - In the API settings → Machine to Machine Applications tab
   - Or via the Application's API permissions
   - Required scopes:
     - `read:me:authentication_methods`
     - `create:me:authentication_methods`
     - `delete:me:authentication_methods`
     - `read:me:enrollments`

5. **Update `.env` file** in `auth0_flutter/example/`:
   ```
   AUTH0_DOMAIN=your-tenant.auth0.com
   AUTH0_CLIENT_ID=your-client-id
   AUTH0_CUSTOM_SCHEME=demo  # optional, for Android custom schemes
   ```

---

## Running the Example App

### Android
```bash
cd auth0_flutter/example
flutter run -d <android-device-or-emulator>
```

### iOS
```bash
cd auth0_flutter/example
flutter run -d <ios-device-or-simulator>
```

### Web (My Account NOT supported)
The My Account card will not appear on web — this is expected behavior.

---

## Test Cases

### Test 1: Login with My Account Audience

**Steps:**
1. Open the example app
2. Expand "My Account API (MFA)" card
3. Tap "Login for My Account"
4. Complete the Universal Login flow
5. Verify green checkmark appears

**Expected:**
- Output shows: `Login successful!` with truncated access token
- The card expands to show all action buttons

**Logs to look for:**
```
[MyAccount] Logging in with audience: https://{domain}/me/ ...
[MyAccount] Login successful!
```

---

### Test 2: Get Authentication Methods (Empty)

**Steps:**
1. After login, tap "Get Auth Methods"

**Expected (fresh user with no MFA):**
- Output: `No authentication methods enrolled.`

**Expected (user with existing MFA):**
- Output lists all enrolled methods with ID, type, phone/email, dates

---

### Test 3: Get Available Factors

**Steps:**
1. Tap "Get Factors"

**Expected:**
- Lists factors like: `sms: enabled`, `email: enabled`, `otp: enabled`, `push: disabled`
- Matches what you've enabled in Dashboard → Security → MFA

---

### Test 4: Enroll Phone (SMS)

**Steps:**
1. Enter a valid phone number (e.g., `+14155551234`)
2. Tap "Enroll" next to the phone field
3. Wait for SMS with OTP code
4. Enter the OTP in the "OTP Code" field
5. Tap "Verify OTP"

**Expected:**
- Step 2 output: Enrollment Challenge with ID and Auth Session
- Step 5 output: `OTP Verified Successfully! Enrollment complete.`

**Error cases:**
- Invalid phone → `MyAccountException: [400] ...`
- Wrong OTP → `MyAccountException: [401] ...`
- SMS factor disabled → `MyAccountException: [403] ...`

---

### Test 5: Enroll Email

**Steps:**
1. Enter a valid email address
2. Tap "Enroll" next to the email field
3. Check inbox for OTP code
4. Enter OTP and tap "Verify OTP"

**Expected:** Same flow as phone enrollment

---

### Test 6: Enroll TOTP (Authenticator App)

**Steps:**
1. Tap "Enroll TOTP"
2. Copy the `TOTP Secret` or `TOTP URI` from the output
3. Add to an authenticator app (Google Authenticator, Authy, etc.)
4. Enter the 6-digit code from the app
5. Tap "Verify OTP"

**Expected:**
- Step 2 output includes: `totpSecret`, `totpUri`, `barcodeUri`
- Step 5: `OTP Verified Successfully!`

---

### Test 7: Enroll Push Notifications

**Steps:**
1. Tap "Enroll Push"
2. Follow platform-specific push enrollment (may need Guardian app)

**Expected:**
- Returns enrollment challenge with barcode URI
- Note: Full push enrollment requires the Auth0 Guardian app

---

### Test 8: Enroll Recovery Code

**Steps:**
1. Tap "Enroll Recovery"
2. Note the recovery code in the output

**Expected:**
- Output includes a `recoveryCode` that can be used as backup MFA

---

### Test 9: Delete Authentication Method

**Steps:**
1. First enroll at least one method (e.g., TOTP)
2. Tap "Get Auth Methods" to verify it exists
3. Tap "Delete Last Method"
4. Tap "Get Auth Methods" again to verify deletion

**Expected:**
- Shows which method was deleted (ID and type)
- Subsequent list no longer includes that method

---

### Test 10: Error Handling

**Test expired/invalid token:**
1. Login, wait for token to expire (or manually invalidate)
2. Try any operation

**Expected:** `MyAccountException: [401] unauthorized - ...`

**Test missing scopes:**
1. Login without `create:me:authentication_methods` scope
2. Try to enroll

**Expected:** `MyAccountException: [403] insufficient_scope - ...`

**Test network error:**
1. Enable airplane mode
2. Try any operation

**Expected:** `MyAccountException` with `isNetworkError: true`

---

## Platform-Specific Testing

### Android-Specific Checks

1. **Verify method channel registration:**
   ```
   adb logcat | grep "auth0.com/auth0_flutter/my_account"
   ```

2. **Process death recovery:**
   - Start enrollment flow
   - Kill the app process
   - Relaunch and verify state

3. **Check native bridge:**
   ```
   adb logcat | grep "MyAccountAPIClient"
   ```

### iOS-Specific Checks

1. **Verify handler registration:**
   - Xcode → Debug Navigator → check `MyAccountHandler` is registered

2. **Console logs:**
   ```
   # In Xcode console or via Console.app
   filter: "Auth0" or "MyAccount"
   ```

3. **Test on both iPhone and iPad**

---

## Debugging Tips

### Enable verbose logging

All My Account API calls are logged to the debug console with the prefix `[MyAccount]`. Monitor the console output:

```bash
# Android
adb logcat | grep -i "myaccount\|auth0"

# iOS (via Xcode console)
# Filter: MyAccount OR Auth0
```

### Common Issues

| Issue | Cause | Fix |
|-------|-------|-----|
| `Login for My Account` fails | Wrong audience | Ensure API exists with identifier `https://{domain}/me/` |
| `403 insufficient_scope` | Missing scopes | Add required scopes to app in API settings |
| `404` on operations | Feature not enabled | Enable My Account API in tenant settings |
| Enrollment returns error | Factor not enabled | Enable the factor in Security → MFA |
| OTP verification fails | Code expired/wrong | Codes typically expire in 5 min, verify correct code |
| Card doesn't appear | Running on web | Expected — My Account is mobile-only |

### Verify Native SDK Versions

The My Account API requires minimum native SDK versions:
- **Android:** Auth0.Android v3.12.0+ (check `auth0_flutter/android/build.gradle`)
- **iOS/macOS:** Auth0.swift v2.18.0+ (check `auth0_flutter/darwin/auth0_flutter.podspec`)

---

## Web Platform

The My Account API is **NOT supported on web**. The `MyAccountCard` widget automatically hides itself on web (`kIsWeb` check). The SPA SDK does not implement authentication method management.

If you run the example app on web, the My Account section will not be visible — this is the expected behavior.

---

## Automated Test Coverage

Unit tests should cover:
1. Method channel serialization/deserialization
2. Exception mapping from PlatformException
3. Options `toMap()` serialization
4. Model `fromMap()` parsing
5. Platform interface method routing

Integration tests require a real Auth0 tenant and are manual (as described above).
