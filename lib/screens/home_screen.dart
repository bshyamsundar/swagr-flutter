import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_providers.dart';
import '../widgets/metric_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _fetching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialFetch());
  }

  Future<void> _initialFetch() async {
    final cached = ref.read(cachedNewsProvider);
    if (cached.hasValue && cached.requireValue.isEmpty) {
      await _fetchNews();
    }
  }

  Future<void> _fetchNews() async {
    setState(() => _fetching = true);
    try {
      await ref.read(cachedNewsProvider.notifier).fetchAndProcessNews();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch news: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _fetching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final watchlistAsync = ref.watch(watchlistProvider);
    final cachedAsync = ref.watch(cachedNewsProvider);
    final selectedTicker = ref.watch(selectedTickerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Sentiment'),
        actions: [
          IconButton(
            icon: _fetching
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            onPressed: _fetching ? null : _fetchNews,
            tooltip: 'Fetch latest news',
          ),
        ],
      ),
      body: watchlistAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (watchlist) {
          if (watchlist.isEmpty) {
            return const Center(
              child: Text('Add tickers to your watchlist to get started.'),
            );
          }

          return Column(
            children: [
              SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    _FilterChip(
                      label: 'All',
                      selected: selectedTicker == null,
                      onSelected: () =>
                          ref.read(selectedTickerProvider.notifier).state = null,
                    ),
                    ...watchlist.map(
                      (t) => _FilterChip(
                        label: t,
                        selected: selectedTicker == t,
                        onSelected: () =>
                            ref.read(selectedTickerProvider.notifier).state = t,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: cachedAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                  data: (items) {
                    final filtered = selectedTicker == null
                        ? items
                        : items
                            .where((c) => c.article.ticker == selectedTicker)
                            .toList();

                    if (filtered.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.article_outlined, size: 48),
                            const SizedBox(height: 12),
                            const Text('No metrics yet.'),
                            const SizedBox(height: 8),
                            FilledButton(
                              onPressed: _fetching ? null : _fetchNews,
                              child: const Text('Fetch News'),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: _fetchNews,
                      child: ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (_, i) => MetricCard(cached: filtered[i]),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pushNamed('/watchlist'),
        icon: const Icon(Icons.playlist_add),
        label: const Text('Watchlist'),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onSelected(),
      ),
    );
  }
}
