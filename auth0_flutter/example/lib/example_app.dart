import 'dart:async';
import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:auth0_flutter/auth0_flutter_web.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'api_card.dart';
import 'constants.dart';
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
  late Auth0Web auth0Web;

  @override
  void initState() {
    super.initState();

    auth0 = Auth0(dotenv.env['AUTH0_DOMAIN']!, dotenv.env['AUTH0_CLIENT_ID']!);
    auth0Web =
        Auth0Web(dotenv.env['AUTH0_DOMAIN']!, dotenv.env['AUTH0_CLIENT_ID']!);
    webAuth =
        auth0.webAuthentication(scheme: dotenv.env['AUTH0_CUSTOM_SCHEME']);
    if (kIsWeb) {
      auth0Web.onLoad().then((final credentials) => setState(() {
            _output = credentials?.idToken ?? '';
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

      final result = await webAuth.login(useHTTPS: true);

      setState(() {
        _isLoggedIn = true;
      });

      output = result.idToken;
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
      } else {
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
      output = result.accessToken;
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

  // DPoP Login Function - Works on Web, Android, and iOS
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
                      // DPoP Button - Works on Web, Android, and iOS
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
