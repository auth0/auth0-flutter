import 'dart:async';

import 'package:flutter/material.dart';

import 'constants.dart';

class PasskeyCard extends StatefulWidget {
  final Future<void> Function(String email) onSignup;
  final Future<void> Function() onLogin;

  const PasskeyCard({
    required this.onSignup,
    required this.onLogin,
    final Key? key,
  }) : super(key: key);

  @override
  PasskeyCardState createState() => PasskeyCardState();
}

class PasskeyCardState extends State<PasskeyCard> {
  String email = '';

  @override
  Widget build(final BuildContext context) {
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Text(
                    "Uses the browser's built-in WebAuthn API "
                    '(navigator.credentials) via @auth0/auth0-spa-js.'),
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Email (for signup)',
                  ),
                  onChanged: (final input) => email = input,
                ),
                ElevatedButton(
                  onPressed: () => widget.onSignup(email),
                  child: const Text('Sign Up with Passkey'),
                ),
                ElevatedButton(
                  onPressed: widget.onLogin,
                  child: const Text('Sign In with Passkey'),
                ),
              ],
            )));
  }
}
