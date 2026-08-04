import '../../auth0_flutter_platform_interface.dart';

/// A multi-factor challenge.
class Challenge {
  /// How the user will get the challenge and prove possession.
  final ChallengeType type;

  /// Out-of-Band (OOB) code.
  final String? oobCode;

  /// When the challenge response includes a `prompt` binding method, your app
  /// needs to prompt the user for the `binding_code` and send it as part of the
  /// request.
  final String? bindingMethod;

  Challenge({required this.type, this.oobCode, this.bindingMethod});

  factory Challenge.fromMap(final Map<dynamic, dynamic> result) => Challenge(
        type:
            ChallengeType.fromString(result['challengeType'] as String),
        oobCode: result['oobCode'] as String?,
        bindingMethod: result['bindingMethod'] as String?,
      );
}
