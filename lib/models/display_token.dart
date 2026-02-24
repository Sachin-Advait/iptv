class DisplayToken {
  final String token;
  final String counter;
  final String service;
  final DateTime calledAt;

  DisplayToken({
    required this.token,
    required this.counter,
    required this.service,
    required this.calledAt,
  });

  factory DisplayToken.fromJson(Map<String, dynamic> json) {
    return DisplayToken(
      token: json['token'] ?? '',
      counter: json['counter'] ?? '',
      service: json['service'] ?? '',
      calledAt: DateTime.parse(json['calledAt'] ?? DateTime.now().toString()),
    );
  }
}

class TVDisplayResponse {
  final List<DisplayToken> latestCalls;
  final List<DisplayToken> nowServing;
  final List<String> upcomingTokens;
  final List<String> holdTokens;
  final String? branchName;

  TVDisplayResponse({
    required this.latestCalls,
    required this.nowServing,
    required this.upcomingTokens,
    required this.holdTokens,
    this.branchName,
  });

  factory TVDisplayResponse.fromJson(Map<String, dynamic> json) {
    return TVDisplayResponse(
      latestCalls:
          (json['latestCalls'] as List?)
              ?.map((item) => DisplayToken.fromJson(item))
              .toList() ??
          [],
      nowServing:
          (json['nowServing'] as List?)
              ?.map((item) => DisplayToken.fromJson(item))
              .toList() ??
          [],
      upcomingTokens: (json['upcomingTokens'] as List<dynamic>)
          .map((e) => e.toString())
          .toList(),
      holdTokens: (json['holdTokens'] as List<dynamic>)
          .map((e) => e.toString())
          .toList(),
      branchName: json['branchName'],
    );
  }
}
