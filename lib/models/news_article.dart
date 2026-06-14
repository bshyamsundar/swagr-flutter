class NewsArticle {
  const NewsArticle({
    required this.id,
    required this.ticker,
    required this.title,
    required this.url,
    required this.rawText,
    required this.publishedAt,
  });

  final String id;
  final String ticker;
  final String title;
  final String url;
  final String rawText;
  final DateTime publishedAt;

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      id: json['id'] as String,
      ticker: json['ticker'] as String,
      title: json['title'] as String,
      url: json['url'] as String,
      rawText: json['raw_text'] as String,
      publishedAt: DateTime.parse(json['published_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'ticker': ticker,
        'title': title,
        'url': url,
        'raw_text': rawText,
        'published_at': publishedAt.toIso8601String(),
      };
}
