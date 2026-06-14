import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';

import '../models/cached_news.dart';
import '../models/rating.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static const String _dbFileName = 'financial_sentiment.db';

  final StoreRef<String, Map<String, Object?>> watchlistStore =
      stringMapStoreFactory.store('watchlist_store');

  final StoreRef<String, Map<String, Object?>> newsCacheStore =
      stringMapStoreFactory.store('news_cache_store');

  final StoreRef<String, Map<String, Object?>> ratingsStore =
      stringMapStoreFactory.store('ratings_store');

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _openDatabase();
    return _database!;
  }

  Future<Database> _openDatabase() async {
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = '${dir.path}/$_dbFileName';
    return databaseFactoryIo.openDatabase(dbPath);
  }

  Future<List<String>> getWatchlist() async {
    final db = await database;
    final records = await watchlistStore.find(db);
    return records.map((r) => r.key).toList()..sort();
  }

  Future<void> addToWatchlist(String ticker) async {
    final db = await database;
    await watchlistStore.record(ticker.toUpperCase()).put(db, {
      'ticker': ticker.toUpperCase(),
      'added_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> removeFromWatchlist(String ticker) async {
    final db = await database;
    await watchlistStore.record(ticker.toUpperCase()).delete(db);
  }

  Future<void> seedDefaultWatchlistIfEmpty() async {
    final existing = await getWatchlist();
    if (existing.isNotEmpty) return;

    const defaults = ['AAPL', 'MSFT', 'GOOGL', 'AMZN', 'NVDA'];
    for (final ticker in defaults) {
      await addToWatchlist(ticker);
    }
  }

  Future<CachedNews?> getCachedNews(String articleId) async {
    final db = await database;
    final record = await newsCacheStore.record(articleId).get(db);
    if (record == null) return null;
    return CachedNews.fromJson(Map<String, dynamic>.from(record));
  }

  Future<void> saveCachedNews(CachedNews cached) async {
    final db = await database;
    await newsCacheStore
        .record(cached.cacheKey)
        .put(db, cached.toJson().cast<String, Object?>());
  }

  Future<List<CachedNews>> getAllCachedNews({String? ticker}) async {
    final db = await database;
    final records = await newsCacheStore.find(db);
    final items = records
        .map((r) => CachedNews.fromJson(Map<String, dynamic>.from(r.value)))
        .toList();

    if (ticker != null) {
      return items.where((c) => c.article.ticker == ticker).toList()
        ..sort((a, b) => b.article.publishedAt.compareTo(a.article.publishedAt));
    }

    items.sort(
      (a, b) => b.article.publishedAt.compareTo(a.article.publishedAt),
    );
    return items;
  }

  Future<void> saveRating(Rating rating) async {
    final db = await database;
    await ratingsStore
        .record(rating.id)
        .put(db, rating.toJson().cast<String, Object?>());
  }

  Future<List<Rating>> getRatingsForTicker(String ticker) async {
    final db = await database;
    final finder = Finder(
      filter: Filter.equals('ticker', ticker.toUpperCase()),
      sortOrders: [SortOrder('timestamp', false)],
    );
    final records = await ratingsStore.find(db, finder: finder);
    return records
        .map((r) => Rating.fromJson(Map<String, dynamic>.from(r.value)))
        .toList();
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
