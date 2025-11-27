import '../request/request_options.dart';

class EmptyRequestOptions implements RequestOptions {
  const EmptyRequestOptions();

  @override
  Map<String, dynamic> toMap() => {};
}
