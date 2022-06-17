import '../../request/request_options.dart';

class GetCredentialsOptions implements RequestOptions {
  final int? minTtl;
  final Set<String> scopes;
  final Map<String, String>? parameters;

  GetCredentialsOptions({
    this.minTtl,
    this.scopes = const {},
    this.parameters,
  });

  @override
  Map<String, dynamic> toMap() => {
        'minTtl': minTtl,
        'scopes': scopes.toList(),
        'parameters': parameters,
      };
}
