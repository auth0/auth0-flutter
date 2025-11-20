import 'dart:async';
import 'dart:developer';

import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:auth0_flutter/auth0_flutter_web.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'constants.dart';

class DpopPocPage extends StatefulWidget {
  final Auth0 auth0;
  final Auth0Web? auth0Web;

  const DpopPocPage({required this.auth0, this.auth0Web, final Key? key})
      : super(key: key);

  @override
  State<DpopPocPage> createState() => _DpopPocPageState();
}

class _DpopPocPageState extends State<DpopPocPage> {
  Credentials? _credentials;
  String _errorMessage = '';

  Future<void> loginWithDPoP() async {
    setState(() {
      _credentials = null;
      _errorMessage = '';
    });

    try {
      Credentials? result;

      if (kIsWeb) {
        // --- WEB LOGIC ---
        if (widget.auth0Web == null) {
          throw Exception('Auth0Web client not available on web platform.');
        }

        // For DPoP, loginWithPopup is often simpler as it doesn't require a full page reload.
        result = await widget.auth0Web!.loginWithPopup(
          audience: 'https://DpopFlutterTest/',
        );
        log('[DPoP PoC - Web] Login successful.');
        log('  - Token Type: ${result.tokenType}');
      } else {
        // --- MOBILE LOGIC (Unchanged) ---
        result = await widget.auth0.webAuthentication().login(
              useDPoP: true,
              audience: 'https://DpopFlutterTest/',
            );
        log('[DPoP PoC - Mobile] Login successful.');
        log('  - Token Type: ${result.tokenType}');
      }

      setState(() {
        _credentials = result;
      });
    } catch (e) {
      log('[DPoP PoC - App] Login failed.', error: e);
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DPoP Proof of Concept'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(padding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: loginWithDPoP,
              child: const Text('Login with DPoP'),
            ),
            const SizedBox(height: 20),
            const Text('Result:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const Divider(),
            if (_credentials != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      'Access Token: ${_credentials!.accessToken.substring(0, _credentials!.accessToken.length < 20 ? _credentials!.accessToken.length : 20)}...'),
                  if (!kIsWeb)
                    Text(
                        'ID Token: ${_credentials!.idToken.substring(0, _credentials!.idToken.length < 20 ? _credentials!.idToken.length : 20)}...'),
                  Text('Token Type: ${_credentials!.tokenType}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('User ID: ${_credentials!.user.sub}'),
                ],
              ),
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}
