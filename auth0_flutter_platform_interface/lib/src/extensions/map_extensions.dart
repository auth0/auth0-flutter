extension MapExtensions on Map<dynamic, dynamic> {
  T? getOrNull<T>(final String name) =>
      containsKey(name) && this[name] is T ? this[name] as T : null;

  T getOrDefault<T>(final String name, final T defaultValue) =>
      containsKey(name) && this[name] is T ? this[name] as T : defaultValue;

  bool getBooleanOrFalse(final String name) => getOrDefault<bool>(name, false);
}
