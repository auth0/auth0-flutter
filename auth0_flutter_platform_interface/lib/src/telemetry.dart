class Telemetry {
  String name;
  String version;

  Telemetry({required this.name, required this.version});

  Map<String, String> toMap() => {
        'name': name,
        'version': version,
      };
}
