/// The location where cached data is stored by the underlying client
/// on the web platform.
enum CacheLocation {
  /// Data is persisted in memory. The cache is lost on page reload.
  memory,

  /// Data is persisted in the browser's local storage.
  ///
  /// **Note**: There are security considerations when using this type of
  /// cache storage. Please see the [Auth0 docs](https://auth0.com/docs/libraries/auth0-single-page-app-sdk#change-storage-options)
  /// to learn more.
  localStorage;

  @override
  String toString() {
    switch (this) {
      case CacheLocation.memory:
        return 'memory';
      case CacheLocation.localStorage:
        return 'localstorage';
    }
  }
}
