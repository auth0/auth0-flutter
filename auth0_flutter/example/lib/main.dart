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
  String _token = 'Unknown';

  @override
  void initState() {
    super.initState();
  }

  Future<void> webAuthLogin() async {
    String token;
    WebAuthLoginResult? result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      result = await Auth0Flutter.webAuthLogin;
      token = result?.accessToken ?? '';
    } on PlatformException {
      token = 'Failed to get token.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _token = token;
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
                      WebAuthCard(webAuthLogin),
                    ]),
              )),
              SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                          padding, 0.0, padding, padding),
                      child: Center(child: Text('With token: $_token')))),
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
  final Future<void> Function() loginAction;

  const WebAuthCard(final this.loginAction, {final Key? key}) : super(key: key);

  @override
  Widget build(final BuildContext context) {
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(padding),
            child: SizedBox(
              width: double.maxFinite,
              child: ElevatedButton(
                onPressed: loginAction,
                child: const Text('Web Auth Login'),
              ),
            )));
  }
}
