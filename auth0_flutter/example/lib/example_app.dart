import 'dart:async';
import 'dart:io' show Platform;
import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:auth0_flutter/auth0_flutter_web.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'api_card.dart';
import 'constants.dart';
import 'passkey_authenticator.dart';
import 'web_auth_card.dart';

class ExampleApp extends StatefulWidget {
  const ExampleApp({final Key? key}) : super(key: key);

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  bool _isLoggedIn = false;
  String _output = '';

  late Auth0 auth0;
  late WebAuthentication webAuth;
  late WindowsWebAuthentication windowsWebAuth;
  late Auth0Web auth0Web;

  @override
  void initState() {
    super.initState();

    auth0 = Auth0(dotenv.env['AUTH0_DOMAIN']!, dotenv.env['AUTH0_CLIENT_ID']!);
    auth0Web =
        Auth0Web(dotenv.env['AUTH0_DOMAIN']!, dotenv.env['AUTH0_CLIENT_ID']!);
    webAuth =
        auth0.webAuthentication(scheme: dotenv.env['AUTH0_CUSTOM_SCHEME']);
    if (Platform.isWindows) {
      windowsWebAuth = auth0.windowsWebAuthentication();
    }
    if (kIsWeb) {
      auth0Web.onLoad().then((final credentials) => setState(() {
            _output = _preview(credentials?.idToken ?? '');
            _isLoggedIn = credentials != null;
          }));
    }
  }

  Future<void> webAuthLogin() async {
    String output = '';

    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      if (kIsWeb) {
        return auth0Web.loginWithRedirect(redirectUrl: 'http://localhost:3000');
      }

      // Use Windows-specific authentication for Windows platform
      if (Platform.isWindows) {
        final result = await windowsWebAuth.login(
          appCustomURL: 'auth0flutter://callback',
          authTimeout: const Duration(minutes: 5),
        );

        setState(() {
          _isLoggedIn = true;
        });
        output = result.idToken.replaceAll(RegExp('.'), '*');
      } else {
        // Use mobile authentication for iOS/Android
        final result = await webAuth.login(
            useHTTPS: true,
            scopes: {'openid', 'profile', 'email', 'offline_access'});
        await auth0.credentialsManager.storeCredentials(result);

        setState(() {
          _isLoggedIn = true;
        });

        output = result.idToken.replaceAll(RegExp(r'.'), '*');
      }
    } catch (e) {
      output = e.toString();
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _output = output;
    });
  }

  Future<void> webAuthLogout() async {
    String output;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      if (kIsWeb) {
        await auth0Web.logout(returnToUrl: 'http://localhost:3000');
      } else if (Platform.isWindows) {
        // Use Windows-specific logout
        await windowsWebAuth.logout(
          appCustomURL: 'auth0flutter://callback',
        );

        setState(() {
          _isLoggedIn = false;
        });
      } else {
        // Use mobile logout for iOS/Android
        await webAuth.logout(useHTTPS: true);

        setState(() {
          _isLoggedIn = false;
        });
      }
      output = 'Logged out.';
    } catch (e) {
      output = e.toString();
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _output = output;
    });
  }

  Future<void> apiLogin(
      final String usernameOrEmail, final String password) async {
    String output;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      final result = await auth0.api.login(
          usernameOrEmail: usernameOrEmail,
          password: password,
          connectionOrRealm: 'Username-Password-Authentication');
      output = _preview(result.accessToken);
    } on ApiException catch (e) {
      output = e.toString();
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _isLoggedIn = true;
      _output = output;
    });
  }

  // DPoP Login Function - Works on Web, Android, and iOS.
  // NOTE: DPoP is not yet implemented on Windows; the button is
  // hidden on that platform.
  Future<void> dpopLogin() async {
    String output = '';

    try {
      if (kIsWeb) {
        // Web: Use popup-based login with DPoP
        final auth0WebDPoP = Auth0Web(
          dotenv.env['AUTH0_DOMAIN']!,
          dotenv.env['AUTH0_CLIENT_ID']!,
          useDPoP: true,
        );

        // Initialize SDK
        await auth0WebDPoP.onLoad(audience: dotenv.env['AUTH0_AUDIENCE']);

        // Login with popup
        final credentials = await auth0WebDPoP.loginWithPopup(
          audience: dotenv.env['AUTH0_AUDIENCE'],
        );

        setState(() {
          _isLoggedIn = true;
        });

        output = 'DPoP Login Successful!\n\n'
            'Token Type: ${credentials.tokenType}\n'
            'Access Token: ${credentials.accessToken.substring(0, 50)}...\n'
            'ID Token: ${credentials.idToken.substring(0, 50)}...\n'
            'Expires At: ${credentials.expiresAt}';
      } else {
        // Mobile (Android/iOS): Use WebAuth with DPoP
        final webAuthDPoP = auth0.webAuthentication(
          scheme: dotenv.env['AUTH0_CUSTOM_SCHEME'],
        );

        final result = await webAuthDPoP.login(
          useDPoP: true, // Enable DPoP for mobile
          useHTTPS: true,
          audience: dotenv.env['AUTH0_AUDIENCE'],
        );

        setState(() {
          _isLoggedIn = true;
        });

        output = 'DPoP Login Successful!\n\n'
            'Token Type: ${result.tokenType}\n'
            'Access Token: ${result.accessToken.substring(0, 50)}...\n'
            'ID Token: ${result.idToken.substring(0, 50)}...';
      }
    } catch (e) {
      output = 'DPoP Login Failed:\n$e';
    }

    if (!mounted) return;

    setState(() {
      _output = output;
    });
  }

  /// Returns a short, safe preview of a token for display.
  String _preview(final String token) =>
      token.length <= 20 ? token : '${token.substring(0, 20)}...';

  /// Builds a redacted, display-safe summary of [credentials].
  ///
  /// Token values are masked so the example never renders raw secrets on
  /// screen; only their presence and non-sensitive metadata are shown.
  String _redactedCredentials(final Credentials credentials) {
    String mask(final String? token) =>
        (token == null || token.isEmpty) ? 'N/A' : '••••••••';

    return 'Access Token: ${mask(credentials.accessToken)}\n'
        'ID Token: ${mask(credentials.idToken)}\n'
        'Refresh Token: ${mask(credentials.refreshToken)}\n'
        'Token Type: ${credentials.tokenType}\n'
        'Expires At: ${credentials.expiresAt}\n'
        'Scopes: ${credentials.scopes.join(' ')}';
  }

  Future<void> passkeyLogin() async {
    String output;
    try {
      // Step 1: Request a login challenge from Auth0.
      output = 'Step 1/2: Requesting challenge...\n';
      setState(() { _output = output; });

      final challenge = await auth0.api.passkeyLoginChallenge(
        connection: dotenv.env['AUTH0_PASSKEY_CONNECTION'],
      );

      output += 'Challenge received!\n'
          '  authSession: ${_preview(challenge.authSession)}\n'
          '  rpId: ${challenge.authParamsPublicKey['rpId']}\n\n'
          'Presenting passkey UI & obtaining credential...\n';
      setState(() { _output = output; });

      // The SDK does not present the passkey UI. Your app obtains the
      // assertion from the platform authenticator — for example via
      // ASAuthorizationController (iOS/macOS) or Credential Manager (Android),
      // typically over your own platform channel — using the `challenge` above,
      // and constructs a [PasskeyCredential] from the WebAuthn assertion.
      final credential = await _obtainLoginCredential(challenge);

      // Step 2: Exchange the credential for Auth0 tokens.
      output += 'Step 2/2: Exchanging credential for tokens...\n';
      setState(() { _output = output; });

      final result = await auth0.api.passkeyCredentialExchange(
        challenge: challenge,
        credential: credential,
        connection: dotenv.env['AUTH0_PASSKEY_CONNECTION'],
      );

      setState(() {
        _isLoggedIn = true;
      });
      output += 'Login successful!\n'
          '${_redactedCredentials(result)}\n'
          'User: ${result.user.name ?? result.user.email ?? result.user.sub}';
    } on ApiException catch (e) {
      output = 'Passkey Login Error:\n'
          'Code: ${e.code}\n'
          'Message: ${e.message}';
    } catch (e) {
      output = 'Passkey Login Failed:\n$e';
    }

    if (!mounted) return;
    setState(() {
      _output = output;
    });
  }

  /// Obtains a login [PasskeyCredential] from the platform authenticator.
  ///
  /// This is intentionally app-side: the SDK exposes only
  /// [AuthenticationApi.passkeyLoginChallenge] and
  /// [AuthenticationApi.passkeyCredentialExchange], leaving the OS passkey UI
  /// to the app. Here we delegate to [PasskeyAuthenticator], which calls the
  /// native platform authenticator over a method channel and maps the resulting
  /// WebAuthn assertion into a [PasskeyCredential].
  Future<PasskeyCredential> _obtainLoginCredential(
    final PasskeyChallenge challenge,
  ) =>
      PasskeyAuthenticator.getAssertion(challenge);

  Future<void> getSSOCredentials() async {
    String output;
    try {
      final ssoCredentials = await auth0.credentialsManager.ssoCredentials();
      final token = ssoCredentials.sessionTransferToken;
      output = 'SSO Credentials:\n\n'
          'Session Transfer Token: ${token.substring(0, 20)}...\n'
          'Token Type: ${ssoCredentials.tokenType}\n'
          'Expires In: ${ssoCredentials.expiresIn}s\n'
          'ID Token: ${ssoCredentials.idToken != null ? '****' : 'N/A'}\n'
          'Refresh Token: '
          '${ssoCredentials.refreshToken != null ? '****' : 'N/A'}';
    } on CredentialsManagerException catch (e) {
      output = 'SSO Error: ${e.code}\n${e.message}';
    } catch (e) {
      output = 'SSO Error: $e';
    }

    if (!mounted) return;

    setState(() {
      _output = output;
    });
  }

  /// Signs up a new user with a passkey.
  ///
  /// The SDK only requests the challenge and exchanges the credential for
  /// tokens; presenting the OS passkey creation UI is left to the app, here via
  /// [_obtainSignupCredential].
  Future<void> passkeySignup() async {
    String output;
    var step = 'challenge';
    try {
      setState(() => _output = 'Step 1/2: requesting signup challenge...');
      final challenge = await auth0.api.passkeySignupChallenge(
        email: 'passkey-${DateTime.now().millisecondsSinceEpoch}@example.com',
        connection: dotenv.env['AUTH0_PASSKEY_CONNECTION'],
      );

      // The SDK does not present the passkey UI. Your app creates the passkey
      // with the platform authenticator — for example via
      // ASAuthorizationController (iOS/macOS) or Credential Manager (Android),
      // typically over your own platform channel — using the `challenge` above,
      // and constructs a [PasskeyCredential] from the WebAuthn attestation.
      step = 'createCredential';
      setState(() => _output = 'Presenting passkey creation UI...');
      final credential = await _obtainSignupCredential(challenge);

      step = 'exchange';
      setState(() => _output = 'Step 2/2: exchanging for tokens...');
      final result = await auth0.api.passkeyCredentialExchange(
        challenge: challenge,
        credential: credential,
        connection: dotenv.env['AUTH0_PASSKEY_CONNECTION'],
      );

      setState(() {
        _isLoggedIn = true;
      });
      output = 'Passkey Signup Successful!\n\n'
          '${_redactedCredentials(result)}\n'
          'User: ${result.user.name ?? result.user.email ?? result.user.sub}';
    } on ApiException catch (e) {
      output = 'Passkey Signup Error (step: $step):\n'
          'Code: ${e.code}\n'
          'Message: ${e.message}\n'
          'Details: ${e.details}';
    } catch (e) {
      output = 'Passkey Signup Failed (step: $step):\n$e';
    }

    if (!mounted) return;
    setState(() {
      _output = output;
    });
  }

  /// Obtains a signup [PasskeyCredential] from the platform authenticator.
  ///
  /// This is intentionally app-side: the SDK exposes only
  /// [AuthenticationApi.passkeySignupChallenge] and
  /// [AuthenticationApi.passkeyCredentialExchange], leaving the OS passkey UI
  /// to the app. Here we delegate to [PasskeyAuthenticator], which calls the
  /// native platform authenticator over a method channel and maps the resulting
  /// WebAuthn attestation into a [PasskeyCredential].
  Future<PasskeyCredential> _obtainSignupCredential(
    final PasskeyChallenge challenge,
  ) =>
      PasskeyAuthenticator.getAttestation(challenge);

  @override
  Widget build(final BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(title: const Text('Auth0 Example')),
          body: CustomScrollView(
            slivers: <Widget>[
              SliverToBoxAdapter(
                  child: Padding(
                padding: const EdgeInsets.all(padding),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ApiCard(action: apiLogin),
                      if (_isLoggedIn)
                        WebAuthCard(
                            label: 'Web Auth Logout', action: webAuthLogout)
                      else
                        WebAuthCard(
                            label: 'Web Auth Login', action: webAuthLogin),
                      const SizedBox(height: 10),
                      // Passkey login & signup — only on mobile (iOS/Android)
                      if (!kIsWeb && !Platform.isWindows) ...[
                        const SizedBox(height: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 12),
                          ),
                          onPressed: passkeyLogin,
                          child: const Text(
                            'Passkey Login',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 12),
                          ),
                          onPressed: passkeySignup,
                          child: const Text(
                            'Passkey Signup',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      // DPoP button — not shown on Windows
                      // (DPoP is not yet implemented on that platform)
                      if (!Platform.isWindows)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 12),
                          ),
                          onPressed: dpopLogin,
                          child: const Text(
                            'DPoP Login',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      if (!kIsWeb && _isLoggedIn) ...[
                        const SizedBox(height: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 12),
                          ),
                          onPressed: getSSOCredentials,
                          child: const Text(
                            'Get SSO Token',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ]),
              )),
              SliverFillRemaining(
                  child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                          padding, 0.0, padding, padding),
                      child: Center(child: Text(_output)))),
            ],
          )),
    );
  }
}
