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

  Future<void> apiLogin(
      final String usernameOrEmail, final String password) async {
    String output;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      /*final result = await auth0.api.login(
          usernameOrEmail: usernameOrEmail,
          password: password,
          connectionOrRealm: 'Username-Password-Authentication');*/

          final result = await auth0.api.signup(email: usernameOrEmail, password: password, connection: 'Username-Password-Authentication', parameters: {
            'test': 'test-foo'
          });
      output = result.email;
    } on ApiException catch (e) {
      output = output = e.statusCode.toString();
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
                      ApiCard(action: apiLogin),
                      if (_isLoggedIn)
                        WebAuthCard(
                            label: 'Web Auth Logout', action: webAuthLogout)
                      else
                        WebAuthCard(
                            label: 'Web Auth Login', action: webAuthLogin),
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

class ApiCard extends StatefulWidget {
  final Future<void> Function(String usernameOrEmail, String password) action;
  const ApiCard({required final this.action, final Key? key}) : super(key: key);

  @override
  ApiCardState createState() {
    // ignore: no_logic_in_create_state
    return ApiCardState();
  }
}

class ApiCardState extends State<ApiCard> {
  final _formKey = GlobalKey<FormState>();
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
                    onChanged: (final input) => usernameOrEmail = input,
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
                        widget.action(usernameOrEmail, password);
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

  const WebAuthCard(
      {required final this.label, required final this.action, final Key? key})
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
