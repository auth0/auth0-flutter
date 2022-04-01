import 'dart:async';

import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const ExampleApp());
}

const double padding = 24.0;

class ExampleApp extends StatefulWidget {
  const ExampleApp({final Key? key}) : super(key: key);

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  bool _isLoggedIn = false;
  String _output = '';

  final auth0 = Auth0('test-domain', 'test-client');

  @override
  void initState() {
    super.initState();
  }

  Future<void> webAuthLogin() async {
    String output;

    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      final result = await auth0.webAuthentication.login();
      output = result.idToken;

      setState(() {
        _isLoggedIn = true;
      });
    } on PlatformException {
      output = 'Failed to get token.';
    } on WebAuthException catch (e) {
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
      await auth0.webAuthentication.logout();
      output = 'Logged out.';

      setState(() {
        _isLoggedIn = false;
      });
    } on PlatformException {
      output = 'Failed to logout.';
    } on WebAuthException catch (e) {
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
                      const FormCard(),
                      if (_isLoggedIn)
                        WebAuthCard('Web Auth Logout', webAuthLogout)
                      else
                        WebAuthCard('Web Auth Login', webAuthLogin),
                    ]),
              )),
              SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                          padding, 0.0, padding, padding),
                      child: Center(child: Text(_output)))),
            ],
          )),
    );
  }
}

class FormCard extends StatefulWidget {
  const FormCard({final Key? key}) : super(key: key);

  @override
  FormCardState createState() {
    return FormCardState();
  }
}

class FormCardState extends State<FormCard> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(final BuildContext context) {
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(padding),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  TextFormField(
                    decoration: const InputDecoration(
                      hintText: 'Username or email',
                    ),
                    validator: (final String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an username or email';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      hintText: 'Password',
                    ),
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    validator: (final String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      return null;
                    },
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState != null &&
                          _formKey.currentState!.validate()) {
                        // Process data.
                      }
                    },
                    child: const Text('API Login'),
                  ),
                ],
              ),
            )));
  }
}

class WebAuthCard extends StatelessWidget {
  final String label;
  final Future<void> Function() action;

  const WebAuthCard(final this.label, final this.action, {final Key? key})
      : super(key: key);

  @override
  Widget build(final BuildContext context) {
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(padding),
            child: SizedBox(
              width: double.maxFinite,
              child: ElevatedButton(
                onPressed: action,
                child: Text(label),
              ),
            )));
  }
}
