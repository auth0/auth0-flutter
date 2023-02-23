import '../../request/request_options.dart';

// ignore: comment_references
/// Options used to check if a non-expired pair of [Credentials] can be obtained
///  using the `CredentialsManagerPlatform`.
class HasValidCredentialsOptions implements RequestOptions {
  final int minTtl;

  HasValidCredentialsOptions({this.minTtl = 0});

  @override
  Map<String, dynamic> toMap() => {'minTtl': minTtl};
}
