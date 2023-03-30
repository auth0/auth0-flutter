enum CacheMode {
  on,
  off,
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
