import '../../auth0_flutter_platform_interface.dart';
import 'request.dart';

/// Request object for DPoP utility operations.
///
/// Unlike [ApiRequest], DPoP operations are utility functions that don't
/// require account information or user agent since they only perform local
/// cryptographic operations.
class DPoPRequest<TOptions> {
  final TOptions options;

  const DPoPRequest({required this.options});
}
