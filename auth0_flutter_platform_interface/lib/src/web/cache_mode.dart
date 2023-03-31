/// How the cache is to be used when requesting new tokens silently.
enum CacheMode {
  /// The default setting. Reads from the cache first, and falls back to a
  /// request to the server if the cache does not exist, or has expired.
  on,

  /// The cache is ignored and always makes a request to the server for new
  /// tokens.
  off,

  /// The cache is always used and never sends a request to the server.
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
