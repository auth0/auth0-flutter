# Auth0 Flutter - Windows Implementation

This directory contains the Windows-specific implementation for the Auth0 Flutter SDK.

## Features

- ✅ Web Authentication (Login/Logout)
- ✅ PKCE (Proof Key for Code Exchange) support
- ✅ State parameter validation (CSRF protection)
- ✅ HTTP-based callback with friendly redirect page
- ✅ **Custom callback HTML pages (inline or hosted)**
- ✅ Custom scheme fallback support
- ✅ Automatic window focus after authentication

## Authentication Callback Methods

The Windows implementation supports two callback methods:

### 1. HTTP Localhost Callback (Recommended - Default)

**Redirect URI:** `http://localhost:8080/callback`

This method provides the best user experience by:
- Starting a local HTTP server during authentication
- Displaying a friendly "Authentication Successful!" page with auto-close
- Showing a countdown timer before redirecting
- Gracefully handling errors with helpful messages
- No browser tab stuck after login
- **Customizable HTML pages (see Custom Callback Page section)**

**Benefits:**
- ✅ Professional user experience
- ✅ Clear visual feedback
- ✅ No stuck browser tabs
- ✅ Works across all Windows versions
- ✅ No Windows registry configuration required
- ✅ **Fully customizable UI**

### 2. Custom Scheme Callback (Legacy)

**Redirect URI:** `auth0flutter://callback` (or custom)

This method uses Windows protocol activation:
- Registers a custom URL scheme
- Browser redirects to custom scheme
- Windows launches/activates the app
- Environment variable polling to receive callback

**Note:** This method leaves the browser tab stuck on the redirect URL since browsers cannot display custom protocol schemes.

## Configuration

### Auth0 Dashboard Setup

Add the following URL to your **Allowed Callback URLs** in the [Auth0 Dashboard](https://manage.auth0.com/#/applications/):

```
http://localhost:8080/callback
```

### Basic Usage

```dart
final credentials = await auth0.webAuthentication().login();
```

### Custom Redirect URI

```dart
// Use HTTP callback (recommended)
final credentials = await auth0.webAuthentication().login(
  redirectUrl: 'http://localhost:8080/callback',
);

// Or use custom port
final credentials = await auth0.webAuthentication().login(
  redirectUrl: 'http://localhost:3000/callback',
);

// Or use custom scheme (legacy)
final credentials = await auth0.webAuthentication().login(
  redirectUrl: 'auth0flutter://callback',
);
```

### Custom Callback Page (Windows Only)

**NEW:** You can now customize the HTML page shown after successful authentication!

#### Method 1: Hosted URL (Recommended)

Host your custom HTML page on a web server and provide the URL:

```dart
final credentials = await auth0.webAuthentication().login(
  parameters: {
    'customCallbackUrl': 'https://your-domain.com/auth-success.html',
  },
);
```

**Benefits:**
- Easy to update without app redeployment
- Can include images, fonts, and external CSS/JS resources
- Centralized management across multiple apps
- Better for branding consistency

**Example hosted HTML:**
```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Login Successful - YourApp</title>
    <link rel="stylesheet" href="https://your-domain.com/styles.css">
    <style>
        body {
            font-family: 'Helvetica Neue', Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            margin: 0;
        }
        .success-card {
            background: white;
            padding: 60px;
            border-radius: 16px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            text-align: center;
        }
        .logo { width: 80px; margin-bottom: 20px; }
        h1 { color: #2e7d32; font-size: 28px; margin: 0 0 10px; }
        p { color: #666; font-size: 16px; }
    </style>
    <script>
        setTimeout(() => {
            window.close();
            setTimeout(() => {
                document.body.innerHTML = '<div class="success-card"><p>You can now close this window.</p></div>';
            }, 500);
        }, 3000);
    </script>
</head>
<body>
    <div class="success-card">
        <img src="https://your-domain.com/logo.png" alt="Logo" class="logo">
        <h1>✓ Welcome Back!</h1>
        <p>You've successfully logged in.</p>
        <p style="font-size: 14px; color: #999; margin-top: 20px;">
            Redirecting in 3 seconds...
        </p>
    </div>
</body>
</html>
```

#### Method 2: Inline HTML String

Provide the HTML directly as a string in your Flutter code:

```dart
final credentials = await auth0.webAuthentication().login(
  parameters: {
    'customCallbackHtml': '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login Successful</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            margin: 0;
            background: linear-gradient(135deg, #1e3c72 0%, #2a5298 100%);
        }
        .container {
            background: white;
            padding: 40px;
            border-radius: 12px;
            text-align: center;
            box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
        }
        h1 {
            color: #2e7d32;
            font-size: 24px;
            margin: 0 0 10px;
        }
        p {
            color: #666;
            margin: 0;
        }
        .emoji {
            font-size: 48px;
            margin-bottom: 15px;
        }
    </style>
    <script>
        // Auto-close after 3 seconds
        let countdown = 3;
        const timer = setInterval(() => {
            countdown--;
            document.getElementById('countdown').textContent = countdown;
            if (countdown <= 0) {
                clearInterval(timer);
                window.close();
                // Fallback if window.close() doesn't work
                setTimeout(() => {
                    document.querySelector('.container').innerHTML =
                        '<p>You can close this window now.</p>';
                }, 500);
            }
        }, 1000);
    </script>
</head>
<body>
    <div class="container">
        <div class="emoji">🎉</div>
        <h1>Login Successful!</h1>
        <p>Returning to app in <span id="countdown">3</span> seconds...</p>
    </div>
</body>
</html>
''',
  },
);
```

**Priority Order:**
1. `customCallbackUrl` - Fetched from hosted URL (highest priority)
2. `customCallbackHtml` - Inline HTML string
3. Default HTML - Built-in success page (fallback)

**Custom HTML Guidelines:**
- ✅ Include `<meta charset="UTF-8">` for proper character encoding
- ✅ Add auto-close script: `setTimeout(() => window.close(), 3000);`
- ✅ Include fallback message if `window.close()` is blocked by browser
- ✅ Keep inline HTML under 50KB for performance
- ✅ Test on different browsers (Edge, Chrome, Firefox)
- ✅ For hosted URLs, ensure HTTPS is used
- ✅ For hosted URLs, ensure proper CORS headers if loading external resources
- ✅ Consider responsive design if users might resize the window
- ⚠️ Avoid using external scripts that could delay page load
- ⚠️ Don't rely on user interaction to close the window

The implementation automatically detects which callback method to use based on the URI scheme:
- `http://` or `https://` → Uses HTTP listener with customizable HTML page
- Custom scheme → Uses protocol activation

## How It Works

### HTTP Callback Flow

1. **User initiates login** - App calls `auth0.webAuthentication().login()`
2. **Custom HTML prepared** - If `customCallbackUrl` provided, URL is prepared for fetching
3. **PKCE parameters generated** - Code verifier and challenge created
4. **HTTP server starts** - Local server starts listening on `localhost:8080`
5. **Browser opens** - System browser navigates to Auth0 authorization URL
6. **User authenticates** - User logs in with Auth0
7. **Callback received** - Auth0 redirects to `http://localhost:8080/callback?code=...&state=...`
8. **Custom HTML fetched** - If URL provided, HTML is fetched from the hosted server
9. **Page displayed** - Custom or default HTML page shown with success message
10. **State validated** - CSRF state parameter verified
11. **App receives code** - Authorization code extracted from callback
12. **HTTP server closes** - Local server shuts down
13. **Window focused** - Flutter window brought to foreground
14. **Token exchange** - Authorization code exchanged for access token
15. **User logged in** - Credentials returned to Flutter app

## Security

- **PKCE (Proof Key for Code Exchange)** - Prevents authorization code interception attacks
- **State Parameter Validation** - Protects against CSRF attacks by comparing state between request and callback
- **Secure Random Generation** - Uses OpenSSL's `RAND_bytes()` for cryptographic randomness
- **Localhost Only** - HTTP server only listens on `127.0.0.1`
- **Timeout Protection** - Server automatically closes after 180 seconds
- **Single-Use Callback** - Server closes immediately after receiving callback
- **HTTPS for Hosted HTML** - Custom callback URLs should use HTTPS to prevent man-in-the-middle attacks

## Dependencies

The Windows implementation uses:
- **cpprestsdk**: HTTP client/server and JSON parsing
- **OpenSSL**: SHA256 hashing and random number generation for PKCE
- **Boost**: Utility libraries
- **Windows API**: Window management and environment variables

## Troubleshooting

### Browser tab stuck after login

If you're experiencing stuck browser tabs, ensure you're using the HTTP callback method:

```dart
// Make sure you're using http:// redirect
final credentials = await auth0.webAuthentication().login(
  redirectUrl: 'http://localhost:8080/callback', // ✅ This displays friendly page
);
```

And add `http://localhost:8080/callback` to your **Allowed Callback URLs** in the Auth0 Dashboard.

### Custom HTML not showing

If your custom HTML isn't appearing:

1. **Check the URL is accessible**: Test the `customCallbackUrl` in a browser
2. **Verify HTTPS**: Ensure hosted URLs use HTTPS
3. **Check server response**: Ensure the server returns `Content-Type: text/html`
4. **Review error logs**: Check Windows debug output for fetch errors
5. **Test fallback**: Try using `customCallbackHtml` to test if issue is with URL fetch
6. **Validate HTML**: Ensure your HTML is valid and doesn't have syntax errors

### Firewall blocking localhost

If Windows Firewall blocks the HTTP server:
1. You'll see a Windows Security Alert
2. Click "Allow access" to permit the HTTP listener
3. Or add a firewall rule for your Flutter app

### Custom port already in use

If port 8080 is already in use, choose a different port:

```dart
final credentials = await auth0.webAuthentication().login(
  redirectUrl: 'http://localhost:3000/callback',
);
```

Remember to update your Auth0 Dashboard Allowed Callback URLs accordingly.

## Example Usage

### Basic Login

```dart
import 'package:auth0_flutter/auth0_flutter.dart';

final auth0 = Auth0('YOUR_DOMAIN', 'YOUR_CLIENT_ID');

// Login with default HTML
try {
  final credentials = await auth0.webAuthentication().login(
    redirectUrl: 'http://localhost:8080/callback',
    scopes: {'openid', 'profile', 'email'},
  );

  print('Access Token: ${credentials.accessToken}');
  print('User: ${credentials.user}');
} catch (e) {
  print('Login failed: $e');
}
```

### Login with Custom Hosted HTML

```dart
// Login with custom branded page
final credentials = await auth0.webAuthentication().login(
  redirectUrl: 'http://localhost:8080/callback',
  parameters: {
    'customCallbackUrl': 'https://myapp.com/auth/success.html',
  },
  scopes: {'openid', 'profile', 'email'},
);
```

### Login with Custom Inline HTML

```dart
// Login with inline custom HTML
final credentials = await auth0.webAuthentication().login(
  redirectUrl: 'http://localhost:8080/callback',
  parameters: {
    'customCallbackHtml': '''
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <title>Success</title>
        <script>setTimeout(() => window.close(), 2000);</script>
      </head>
      <body style="font-family: Arial; text-align: center; padding: 50px;">
        <h1 style="color: green;">✓ Success!</h1>
        <p>Logged in successfully. Closing...</p>
      </body>
      </html>
    ''',
  },
  scopes: {'openid', 'profile', 'email'},
);
```

### Logout

```dart
// Logout
try {
  await auth0.webAuthentication().logout();
  print('Logged out successfully');
} catch (e) {
  print('Logout failed: $e');
}
```

## Contributing

When contributing to the Windows implementation:
1. Follow the existing code style
2. Add tests for new functionality
3. Update this README if adding new features
4. Test on Windows 10 and Windows 11
5. Ensure backward compatibility
6. Test custom HTML feature with various HTML structures
