class LogoutOptions {
  final String? returnTo;
  final bool? federated;
  final Future<void> Function(String url)? openUrl;

  LogoutOptions({this.returnTo, this.federated, this.openUrl});
}
