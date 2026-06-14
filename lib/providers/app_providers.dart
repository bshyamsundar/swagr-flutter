import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cached_news.dart';
import '../models/price_target.dart';
import '../models/rating.dart';
import '../services/database_helper.dart';
import '../services/news_service.dart';
import '../services/openai_service.dart';
import '../services/price_target_service.dart';
import '../services/target_calculator.dart';

final databaseHelperProvider = Provider<DatabaseHelper>(
  (ref) => DatabaseHelper.instance,
);

final newsServiceProvider = Provider<NewsService>((ref) => NewsService());

final openAiServiceProvider = Provider<OpenAiService>((ref) => OpenAiService());

final priceTargetServiceProvider = Provider<PriceTargetService>(
  (ref) => PriceTargetService(),
);

final watchlistProvider =
    AsyncNotifierProvider<WatchlistNotifier, List<String>>(
  WatchlistNotifier.new,
);

class WatchlistNotifier extends AsyncNotifier<List<String>> {
  @override
  Future<List<String>> build() async {
    final db = ref.read(databaseHelperProvider);
    await db.seedDefaultWatchlistIfEmpty();
    return db.getWatchlist();
  }

  Future<void> addTicker(String ticker) async {
    final db = ref.read(databaseHelperProvider);
    await db.addToWatchlist(ticker);
    ref.invalidateSelf();
  }

  Future<void> removeTicker(String ticker) async {
    final db = ref.read(databaseHelperProvider);
    await db.removeFromWatchlist(ticker);
    ref.invalidateSelf();
  }
}

final cachedNewsProvider =
    AsyncNotifierProvider<CachedNewsNotifier, List<CachedNews>>(
  CachedNewsNotifier.new,
);

class CachedNewsNotifier extends AsyncNotifier<List<CachedNews>> {
  @override
  Future<List<CachedNews>> build() async {
    final db = ref.read(databaseHelperProvider);
    return db.getAllCachedNews();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }

  Future<void> fetchAndProcessNews() async {
    final db = ref.read(databaseHelperProvider);
    final newsService = ref.read(newsServiceProvider);
    final openAi = ref.read(openAiServiceProvider);
    final watchlist = await ref.read(watchlistProvider.future);

    for (final ticker in watchlist) {
      final articles = await newsService.fetchNewsForTicker(ticker);
      for (final article in articles) {
        final existing = await db.getCachedNews(article.id);
        if (existing != null) continue;

        final metric = await openAi.extractMetric(
          ticker: ticker,
          articleTitle: article.title,
          articleText: article.rawText,
        );

        await db.saveCachedNews(
          CachedNews(
            article: article,
            metric: metric,
            cachedAt: DateTime.now(),
          ),
        );
      }
    }

    ref.invalidateSelf();
  }
}

final selectedTickerProvider = StateProvider<String?>((ref) => null);

final priceTargetProvider =
    FutureProvider.family<PriceTarget, String>((ref, ticker) {
  return ref.read(priceTargetServiceProvider).fetchPriceTarget(ticker);
});

class MetricRatingState {
  const MetricRatingState({
    required this.userRating,
    this.saved = false,
  });

  final double userRating;
  final bool saved;

  MetricRatingState copyWith({double? userRating, bool? saved}) {
    return MetricRatingState(
      userRating: userRating ?? this.userRating,
      saved: saved ?? this.saved,
    );
  }
}

final metricRatingProvider = StateNotifierProvider.family<
    MetricRatingNotifier, MetricRatingState, String>(
  (ref, articleId) => MetricRatingNotifier(ref, articleId),
);

class MetricRatingNotifier extends StateNotifier<MetricRatingState> {
  MetricRatingNotifier(this.ref, this.articleId)
      : super(const MetricRatingState(userRating: 0));

  final Ref ref;
  final String articleId;

  void setRating(double value) {
    state = state.copyWith(userRating: value, saved: false);
  }

  Future<AdjustedPriceTarget?> saveRating(CachedNews cached) async {
    final db = ref.read(databaseHelperProvider);
    final priceTarget =
        await ref.read(priceTargetServiceProvider).fetchPriceTarget(
              cached.article.ticker,
            );

    final adjusted = TargetCalculator.calculate(
      base: priceTarget,
      userRating: state.userRating,
      llmBaseline: cached.metric.baselineSentiment,
      articleDate: cached.article.publishedAt,
    );

    final rating = Rating(
      id: '${articleId}_${DateTime.now().millisecondsSinceEpoch}',
      ticker: cached.article.ticker,
      articleId: articleId,
      timestamp: DateTime.now(),
      userScore: state.userRating,
      llmBaselineScore: cached.metric.baselineSentiment,
      delta: state.userRating - cached.metric.baselineSentiment,
    );

    await db.saveRating(rating);
    await db.saveCachedNews(cached.copyWith(userRating: state.userRating));
    ref.invalidate(cachedNewsProvider);

    state = state.copyWith(saved: true);
    return adjusted;
  }
}

final ratingsForTickerProvider =
    FutureProvider.family<List<Rating>, String>((ref, ticker) {
  return ref.read(databaseHelperProvider).getRatingsForTicker(ticker);
});
