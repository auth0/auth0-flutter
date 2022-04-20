class Account {
  final String domain;
  final String clientId;

  const Account(this.domain, this.clientId);

  Map<String, dynamic> toMap() => {
        'domain': domain,
        'clientId': clientId,
      };
}
