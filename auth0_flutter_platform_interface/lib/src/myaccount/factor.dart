class Factor {
  final String name;
  final bool enabled;

  const Factor({
    required this.name,
    required this.enabled,
  });

  factory Factor.fromMap(final Map<String, dynamic> result) => Factor(
        name: result['name'] as String,
        enabled: result['enabled'] as bool,
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'enabled': enabled,
      };
}
