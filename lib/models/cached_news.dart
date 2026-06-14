import 'extracted_metric.dart';
import 'news_article.dart';

class CachedNews {
  const CachedNews({
    required this.article,
    required this.metric,
    required this.cachedAt,
    this.userRating,
  });

  final NewsArticle article;
  final ExtractedMetric metric;
  final DateTime cachedAt;
  final double? userRating;

  String get cacheKey => article.id;

  factory CachedNews.fromJson(Map<String, dynamic> json) {
    return CachedNews(
      article: NewsArticle.fromJson(json['article'] as Map<String, dynamic>),
      metric: ExtractedMetric.fromJson(json['metric'] as Map<String, dynamic>),
      cachedAt: DateTime.parse(json['cached_at'] as String),
      userRating: json['user_rating'] != null
          ? (json['user_rating'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'article': article.toJson(),
        'metric': metric.toJson(),
        'cached_at': cachedAt.toIso8601String(),
        if (userRating != null) 'user_rating': userRating,
      };

  CachedNews copyWith({double? userRating}) {
    return CachedNews(
      article: article,
      metric: metric,
      cachedAt: cachedAt,
      userRating: userRating ?? this.userRating,
    );
  }
}
