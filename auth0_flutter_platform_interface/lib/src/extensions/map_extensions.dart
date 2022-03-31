extension MapExtensions on Map<dynamic, dynamic> {
  T? getOrNull<T>(final String name) =>
      containsKey(name) && this[name] is T ? this[name] as T : null;
}
