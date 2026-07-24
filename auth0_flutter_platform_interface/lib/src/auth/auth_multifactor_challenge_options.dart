import '../request/request_options.dart';

class AuthMultifactorChallengeOptions implements RequestOptions {
  final String mfaToken;
  final String authenticatorId;

  AuthMultifactorChallengeOptions(
      {required this.mfaToken, required this.authenticatorId});

  @override
  Map<String, dynamic> toMap() =>
      {'mfaToken': mfaToken, 'authenticatorId': authenticatorId};
}
