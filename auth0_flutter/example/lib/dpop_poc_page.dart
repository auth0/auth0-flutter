// lib/dpop_poc_page.dart

import 'dart:async';
import 'dart:developer';

import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'constants.dart';

class DpopPocPage extends StatefulWidget {
  const DpopPocPage({final Key? key}) : super(key: key);

  @override
  State<DpopPocPage> createState() => _DpopPocPageState();
}

class _DpopPocPageState extends State<DpopPocPage> {
  Credentials? _credentials;
  String _errorMessage = '';
  late Auth0 auth0;

  @override
  void initState() {
    super.initState();
    auth0 = Auth0(dotenv.env['AUTH0_DOMAIN']!, dotenv.env['AUTH0_CLIENT_ID']!);
  }

  Future<void> loginWithDPoP() async {
    setState(() {
      _credentials = null;
      _errorMessage = '';
    });

    try {
      log('[DPoP PoC - App] Calling webAuthentication.login with useDPoP: true');
      final result = await auth0.webAuthentication().login(useDPoP: true);
      log('[DPoP PoC - App] Login successful.');
      log('[DPoP PoC - App] Received Credentials:');
      log('  - Access Token: ${result.accessToken.substring(0, 15)}...');
      log('  - ID Token: ${result.idToken.substring(0, 15)}...');
      log('  - Token Type: ${result.tokenType}');
      log('  - User ID: ${result.user.sub}');
      log('  - Scopes: ${result.scopes}');

      setState(() {
        _credentials = result;
      });
    } on WebAuthenticationException catch (e) {
      log('[DPoP PoC - App] Login failed with WebAuthenticationException.',
          error: e);
      setState(() {
        _errorMessage = e.toString();
      });
    } catch (e) {
      log('[DPoP PoC - App] Login failed with an unexpected error.', error: e);
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
                      'Access Token: ${_credentials!.accessToken.substring(0, 20)}...'),
                  Text(
                      'ID Token: ${_credentials!.idToken.substring(0, 20)}...'),
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
