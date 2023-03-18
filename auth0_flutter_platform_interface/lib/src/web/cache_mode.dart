/// The cache strategy used by the underlying client on the web platform.
enum CacheMode {
  /// Reads from the cache or sends a request to Auth0 as needed.
  on,

  /// Ignores the cache and always sends s request to Auth0.
  off,

  /// Only reads from the cache and never sends a request to Auth0.
  cacheOnly;

  @override
  String toString() {
    switch (this) {
      case CacheMode.on:
        return 'on';
      case CacheMode.off:
        return 'off';
      case CacheMode.cacheOnly:
        return 'cache-only';
    }
  }
}
