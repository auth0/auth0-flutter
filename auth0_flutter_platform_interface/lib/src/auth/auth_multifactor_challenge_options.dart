import './challenge_type.dart';
import '../request/request_options.dart';

class AuthMultifactorChallengeOptions implements RequestOptions {
  final String mfaToken;
  final List<ChallengeType>? types;
  final String? authenticatorId;
  final Map<String, String> parameters;

  AuthMultifactorChallengeOptions(
      {required this.mfaToken,
      this.types,
      this.authenticatorId,
      this.parameters = const {}});

  @override
  Map<String, dynamic> toMap() => {
        'mfaToken': mfaToken,
        'types': types?.map((final e) => e.value).toList(),
        'authenticatorId': authenticatorId,
        'parameters': parameters
      };
}
