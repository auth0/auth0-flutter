import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'example_app.dart';

Future<dynamic> main() async {
  await dotenv.load();
  runApp(const ExampleApp());
}
