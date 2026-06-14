class Rating {
  const Rating({
    required this.id,
    required this.ticker,
    required this.articleId,
    required this.timestamp,
    required this.userScore,
    required this.llmBaselineScore,
    required this.delta,
  });

  final String id;
  final String ticker;
  final String articleId;
  final DateTime timestamp;
  final double userScore;
  final double llmBaselineScore;
  final double delta;

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      id: json['id'] as String,
      ticker: json['ticker'] as String,
      articleId: json['article_id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      userScore: (json['user_score'] as num).toDouble(),
      llmBaselineScore: (json['llm_baseline_score'] as num).toDouble(),
      delta: (json['delta'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'ticker': ticker,
        'article_id': articleId,
        'timestamp': timestamp.toIso8601String(),
        'user_score': userScore,
        'llm_baseline_score': llmBaselineScore,
        'delta': delta,
      };
}
