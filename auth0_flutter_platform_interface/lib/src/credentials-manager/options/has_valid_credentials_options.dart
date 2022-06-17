import '../../request/request_options.dart';

class HasValidCredentialsOptions implements RequestOptions {
  final int? minTtl;

  HasValidCredentialsOptions({this.minTtl});

  @override
  Map<String, dynamic> toMap() => {'minTtl': minTtl};
}
