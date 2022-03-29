extension ObjectListExtensions on List<Object?> {
  Set<T> toTypedSet<T>() => map((final e) => e as T).toSet();
}
