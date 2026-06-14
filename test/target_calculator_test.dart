import 'package:flutter_test/flutter_test.dart';

import 'package:financial_sentiment/services/target_calculator.dart';
import 'package:financial_sentiment/models/price_target.dart';

void main() {
  group('TargetCalculator', () {
    final base = PriceTarget(
      ticker: 'AAPL',
      high: 250,
      low: 180,
      median: 215,
      currentPrice: 195,
    );

    test('bullish user rating increases targets', () {
      final result = TargetCalculator.calculate(
        base: base,
        userRating: 0.8,
        llmBaseline: 0.3,
        articleDate: DateTime.now(),
      );

      expect(result.delta, closeTo(0.5, 0.001));
      expect(result.adjustedMedian, greaterThan(base.median));
    });

    test('bearish user rating decreases targets', () {
      final result = TargetCalculator.calculate(
        base: base,
        userRating: -0.5,
        llmBaseline: 0.2,
        articleDate: DateTime.now(),
      );

      expect(result.delta, closeTo(-0.7, 0.001));
      expect(result.adjustedMedian, lessThan(base.median));
    });

    test('older articles have weaker adjustment', () {
      final recent = TargetCalculator.calculate(
        base: base,
        userRating: 1.0,
        llmBaseline: 0.0,
        articleDate: DateTime.now(),
      );

      final old = TargetCalculator.calculate(
        base: base,
        userRating: 1.0,
        llmBaseline: 0.0,
        articleDate: DateTime.now().subtract(const Duration(days: 30)),
      );

      expect(old.decayedDelta.abs(), lessThan(recent.decayedDelta.abs()));
    });
  });
}
