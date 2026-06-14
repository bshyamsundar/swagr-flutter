class PriceTarget {
  const PriceTarget({
    required this.ticker,
    required this.high,
    required this.low,
    required this.median,
    required this.currentPrice,
  });

  final String ticker;
  final double high;
  final double low;
  final double median;
  final double currentPrice;

  factory PriceTarget.fromJson(Map<String, dynamic> json) {
    return PriceTarget(
      ticker: json['ticker'] as String,
      high: (json['high'] as num).toDouble(),
      low: (json['low'] as num).toDouble(),
      median: (json['median'] as num).toDouble(),
      currentPrice: (json['current_price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'ticker': ticker,
        'high': high,
        'low': low,
        'median': median,
        'current_price': currentPrice,
      };
}

class AdjustedPriceTarget {
  const AdjustedPriceTarget({
    required this.ticker,
    required this.base,
    required this.adjustedHigh,
    required this.adjustedLow,
    required this.adjustedMedian,
    required this.delta,
    required this.decayedDelta,
    required this.adjustmentPercent,
  });

  final String ticker;
  final PriceTarget base;
  final double adjustedHigh;
  final double adjustedLow;
  final double adjustedMedian;
  final double delta;
  final double decayedDelta;
  final double adjustmentPercent;
}
