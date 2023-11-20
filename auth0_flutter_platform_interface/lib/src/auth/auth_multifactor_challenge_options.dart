import '../request/request_options.dart';
import './challenge_type.dart';

class AuthMultifactorChallengeOptions implements RequestOptions {
  final String mfaToken;
  final List<ChallengeType>? types;
  final String? authenticatorId;

  AuthMultifactorChallengeOptions(
      {required this.mfaToken,
      this.types,
      this.authenticatorId});

  @override
  Map<String, dynamic> toMap() => {
        'mfaToken': mfaToken,
        'types': types?.map((final e) => e.value).toList(),
        'authenticatorId': authenticatorId
      };
}
