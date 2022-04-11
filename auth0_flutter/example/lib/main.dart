import 'dart:async';

import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<dynamic> main() async {
  await dotenv.load();
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

  late Auth0 auth0;

  @override
  void initState() {
    super.initState();
    auth0 = Auth0(dotenv.env['AUTH0_DOMAIN']!, dotenv.env['AUTH0_CLIENT_ID']!);
  }

  Future<void> webAuthLogin() async {
    String output;

    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      final result = await auth0.webAuthentication
          .login(scheme: dotenv.env['AUTH0_CUSTOM_SCHEME']);

      output = result.idToken;

      setState(() {
        _isLoggedIn = true;
      });
    } on PlatformException catch (e) {
      output = e.toString();
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
      await auth0.webAuthentication
          .logout(scheme: dotenv.env['AUTH0_CUSTOM_SCHEME']);

      output = 'Logged out.';

      setState(() {
        _isLoggedIn = false;
      });
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

  Future<void> authLogin(
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
      output = 'Failed to get token: ${e.message}';
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
                      AuthCard(action: authLogin),
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

class AuthCard extends StatefulWidget {
  final Future<void> Function(String usernameOrEmail, String password) action;

  const AuthCard({final Key? key, required final this.action})
      : super(key: key);

  @override
  AuthCardState createState() {
    // ignore: no_logic_in_create_state
    return AuthCardState(action);
  }
}

class AuthCardState extends State<AuthCard> {
  final _formKey = GlobalKey<FormState>();

  final Future<void> Function(String usernammeOrEmail, String password) action;

  AuthCardState(final this.action);

  String usernameOrEmail = '';
  String password = '';

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
                          return 'Please enter a username or email';
                        }
                        return null;
                      },
                      onChanged: (final input) => usernameOrEmail = input),
                  TextFormField(
                    decoration: const InputDecoration(
                      hintText: 'Password',
                    ),
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    onChanged: (final input) => password = input,
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
                        action(usernameOrEmail, password);
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
