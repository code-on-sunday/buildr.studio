class TokenUsage {
  TokenUsage({
    required this.balance,
    required this.inputTokens,
    required this.outputTokens,
  });

  final double balance;
  final int inputTokens;
  final int outputTokens;

  factory TokenUsage.fromJson(Map<String, dynamic> json) {
    return TokenUsage(
      balance: json['balance'].toDouble(),
      inputTokens: json['inputTokens'],
      outputTokens: json['outputTokens'],
    );
  }
}
