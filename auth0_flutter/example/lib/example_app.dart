import 'dart:async';

import 'package:auth0_flutter/auth0_flutter.dart';
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
