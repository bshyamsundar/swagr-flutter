import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_providers.dart';

class WatchlistScreen extends ConsumerStatefulWidget {
  const WatchlistScreen({super.key});

  @override
  ConsumerState<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends ConsumerState<WatchlistScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _addTicker() async {
    final ticker = _controller.text.trim().toUpperCase();
    if (ticker.isEmpty) return;

    await ref.read(watchlistProvider.notifier).addTicker(ticker);
    _controller.clear();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added $ticker to watchlist')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final watchlistAsync = ref.watch(watchlistProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Watchlist')),
      body: watchlistAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (tickers) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        labelText: 'Ticker symbol',
                        hintText: 'e.g. AAPL',
                        border: OutlineInputBorder(),
                      ),
                      textCapitalization: TextCapitalization.characters,
                      onSubmitted: (_) => _addTicker(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: _addTicker,
                    child: const Text('Add'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: tickers.isEmpty
                  ? const Center(child: Text('No tickers in watchlist.'))
                  : ListView.builder(
                      itemCount: tickers.length,
                      itemBuilder: (_, i) {
                        final ticker = tickers[i];
                        return ListTile(
                          leading: CircleAvatar(
                            child: Text(ticker[0]),
                          ),
                          title: Text(
                            ticker,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: const Text('S&P 500 tracked'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => ref
                                .read(watchlistProvider.notifier)
                                .removeTicker(ticker),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
