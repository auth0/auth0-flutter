class Factor {
  final String type;
  final List<String>? usage;

  const Factor({
    required this.type,
    this.usage,
  });

  factory Factor.fromMap(final Map<String, dynamic> result) => Factor(
        type: result['type'] as String,
        usage: (result['usage'] as List<dynamic>?)
            ?.map((final e) => e as String)
            .toList(),
      );

  Map<String, dynamic> toMap() => {
        'type': type,
        'usage': usage,
      };
}
