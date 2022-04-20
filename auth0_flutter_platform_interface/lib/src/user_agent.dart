class UserAgent {
  String name;
  String version;

  UserAgent({required this.name, required this.version});

  Map<String, String> toMap() => {
        'name': name,
        'version': version,
      };
}
