import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/cached_news.dart';
import '../models/price_target.dart';
import '../providers/app_providers.dart';

class MetricCard extends ConsumerStatefulWidget {
  const MetricCard({super.key, required this.cached});

  final CachedNews cached;

  @override
  ConsumerState<MetricCard> createState() => _MetricCardState();
}

class _MetricCardState extends ConsumerState<MetricCard> {
  AdjustedPriceTarget? _adjusted;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.cached.userRating;
    if (existing != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(metricRatingProvider(widget.cached.cacheKey).notifier)
            .setRating(existing);
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(metricRatingProvider(widget.cached.cacheKey).notifier)
            .setRating(widget.cached.metric.baselineSentiment);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ratingState =
        ref.watch(metricRatingProvider(widget.cached.cacheKey));
    final dateFormat = DateFormat.yMMMd();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _TickerChip(ticker: widget.cached.article.ticker),
                const Spacer(),
                Text(
                  dateFormat.format(widget.cached.article.publishedAt),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              widget.cached.metric.displayLabel,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.cached.metric.sentimentReasoning,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade700,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'LLM baseline: ${widget.cached.metric.baselineSentiment.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const Divider(height: 24),
            _SentimentSlider(
              value: ratingState.userRating,
              onChanged: (v) => ref
                  .read(metricRatingProvider(widget.cached.cacheKey).notifier)
                  .setRating(v),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _saving
                    ? null
                    : () async {
                        setState(() => _saving = true);
                        try {
                          final result = await ref
                              .read(
                                metricRatingProvider(widget.cached.cacheKey)
                                    .notifier,
                              )
                              .saveRating(widget.cached);
                          if (mounted) setState(() => _adjusted = result);
                        } finally {
                          if (mounted) setState(() => _saving = false);
                        }
                      },
                icon: _saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(_saving ? 'Saving...' : 'Save Rating'),
              ),
            ),
            if (_adjusted != null) ...[
              const SizedBox(height: 16),
              PriceTargetDisplay(adjusted: _adjusted!),
            ],
          ],
        ),
      ),
    );
  }
}

class _TickerChip extends StatelessWidget {
  const _TickerChip({required this.ticker});

  final String ticker;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        ticker,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}

class _SentimentSlider extends StatelessWidget {
  const _SentimentSlider({
    required this.value,
    required this.onChanged,
  });

  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final color = _sentimentColor(value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Bearish', style: TextStyle(color: Colors.red.shade700)),
            Text(
              value.toStringAsFixed(2),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: color,
              ),
            ),
            Text('Bullish', style: TextStyle(color: Colors.green.shade700)),
          ],
        ),
        Slider(
          value: value,
          min: -1.0,
          max: 1.0,
          divisions: 40,
          label: value.toStringAsFixed(2),
          activeColor: color,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Color _sentimentColor(double v) {
    if (v > 0.2) return Colors.green.shade600;
    if (v < -0.2) return Colors.red.shade600;
    return Colors.orange.shade600;
  }
}

class PriceTargetDisplay extends StatelessWidget {
  const PriceTargetDisplay({super.key, required this.adjusted});

  final AdjustedPriceTarget adjusted;

  @override
  Widget build(BuildContext context) {
    final pct = adjusted.adjustmentPercent * 100;
    final pctLabel =
        '${pct >= 0 ? '+' : ''}${pct.toStringAsFixed(1)}%';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Adjusted Price Target — ${adjusted.ticker}',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          _TargetRow(
            label: 'Low',
            base: adjusted.base.low,
            adjusted: adjusted.adjustedLow,
          ),
          _TargetRow(
            label: 'Median',
            base: adjusted.base.median,
            adjusted: adjusted.adjustedMedian,
          ),
          _TargetRow(
            label: 'High',
            base: adjusted.base.high,
            adjusted: adjusted.adjustedHigh,
          ),
          const SizedBox(height: 8),
          Text(
            'Sentiment delta: ${adjusted.delta.toStringAsFixed(2)} '
            '(decayed: ${adjusted.decayedDelta.toStringAsFixed(2)}) → $pctLabel',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _TargetRow extends StatelessWidget {
  const _TargetRow({
    required this.label,
    required this.base,
    required this.adjusted,
  });

  final String label;
  final double base;
  final double adjusted;

  @override
  Widget build(BuildContext context) {
    final changed = (adjusted - base).abs() > 0.01;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(width: 56, child: Text(label)),
          Text('\$${base.toStringAsFixed(2)}', style: const TextStyle(color: Colors.grey)),
          const Text('  →  '),
          Text(
            '\$${adjusted.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: changed
                  ? (adjusted > base ? Colors.green.shade700 : Colors.red.shade700)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
