import 'dart:async';

import 'package:flutter/material.dart';

import 'constants.dart';

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
                child: Semantics(
                  label: label,
                  child: ElevatedButton(
                    key: Key(label),
                    onPressed: action,
                    child: Text(label),
                  ),
                ))));
  }
}
