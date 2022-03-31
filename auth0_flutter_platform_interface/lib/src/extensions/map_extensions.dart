extension MapExtensions on Map<dynamic, dynamic> {
  T? getAs<T>(final String name) =>
      containsKey(name) && this[name] is T ? this[name] as T : null;
}
