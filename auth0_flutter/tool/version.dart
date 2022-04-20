import 'dart:io';
import 'package:pubspec_yaml/pubspec_yaml.dart';

Future<String> getPluginVersion() async {
  final pubspecYaml = File('pubspec.yaml').readAsStringSync().toPubspecYaml();
  return pubspecYaml.version.valueOr(() => '');
}

Future<void> updatePluginVersion(final String version) async {
  const versionFileDirectory = 'lib/src';
  const versionFileName = 'version.dart';
  const filename = '$versionFileDirectory/$versionFileName';

  stdout.write("Updating plugin version to '$version' in $filename");

  await File(filename).writeAsString("const String version = '$version';\n");
}

// To execute this script, run `dart tool/version.dart` from the `auth0_flutter` directory
Future<dynamic> main() async {
  final version = await getPluginVersion();
  await updatePluginVersion(version);
}
