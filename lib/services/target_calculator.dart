import 'dart:math';

import '../models/price_target.dart';

/// Applies sentiment delta with exponential time decay to analyst price targets.
class TargetCalculator {
  /// Half-life in days for exponential decay of sentiment impact.
  static const double halfLifeDays = 7.0;

  /// Each full unit of decayed delta shifts targets by this percentage.
  static const double sensitivity = 0.05;

  static double timeDecay(DateTime articleDate) {
    final daysOld = DateTime.now().difference(articleDate).inHours / 24.0;
    return exp(-ln2 * daysOld / halfLifeDays);
  }

  static const double ln2 = 0.6931471805599453;

  static AdjustedPriceTarget calculate({
    required PriceTarget base,
    required double userRating,
    required double llmBaseline,
    required DateTime articleDate,
  }) {
    final delta = userRating - llmBaseline;
    final decay = timeDecay(articleDate);
    final decayedDelta = delta * decay;
    final adjustmentPercent = decayedDelta * sensitivity;

    return AdjustedPriceTarget(
      ticker: base.ticker,
      base: base,
      adjustedHigh: base.high * (1 + adjustmentPercent),
      adjustedLow: base.low * (1 + adjustmentPercent),
      adjustedMedian: base.median * (1 + adjustmentPercent),
      delta: delta,
      decayedDelta: decayedDelta,
      adjustmentPercent: adjustmentPercent,
    );
  }
}
