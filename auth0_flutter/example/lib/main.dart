import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_driver/driver_extension.dart';

import 'example_app.dart';

Future<dynamic> main() async {
  enableFlutterDriverExtension();

  await dotenv.load();
  runApp(const ExampleApp());
}
