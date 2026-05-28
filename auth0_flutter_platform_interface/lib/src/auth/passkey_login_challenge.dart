class PasskeyLoginChallenge {
  final String authSession;
  final Map<String, dynamic> authParamsPublicKey;

  const PasskeyLoginChallenge({
    required this.authSession,
    required this.authParamsPublicKey,
  });

  factory PasskeyLoginChallenge.fromMap(final Map<dynamic, dynamic> result) =>
      PasskeyLoginChallenge(
        authSession: result['authSession'] as String,
        authParamsPublicKey: Map<String, dynamic>.from(
            result['authParamsPublicKey'] as Map<dynamic, dynamic>),
      );

  Map<String, dynamic> toMap() => {
        'authSession': authSession,
        'authParamsPublicKey': authParamsPublicKey,
      };
}
