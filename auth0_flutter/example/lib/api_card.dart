import 'dart:async';

import 'package:flutter/material.dart';

import 'constants.dart';

class ApiCard extends StatefulWidget {
  final Future<void> Function(String usernameOrEmail, String password) action;
  const ApiCard({required this.action, final Key? key}) : super(key: key);

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
