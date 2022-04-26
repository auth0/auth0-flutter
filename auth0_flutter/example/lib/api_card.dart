import 'dart:async';

import 'package:flutter/material.dart';

import 'constants.dart';

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
