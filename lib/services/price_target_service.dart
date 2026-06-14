import '../models/price_target.dart';

class PriceTargetService {
  static const _mockTargets = <String, PriceTarget>{
    'AAPL': PriceTarget(
      ticker: 'AAPL',
      high: 250.0,
      low: 180.0,
      median: 215.0,
      currentPrice: 195.0,
    ),
    'MSFT': PriceTarget(
      ticker: 'MSFT',
      high: 500.0,
      low: 380.0,
      median: 440.0,
      currentPrice: 415.0,
    ),
    'GOOGL': PriceTarget(
      ticker: 'GOOGL',
      high: 210.0,
      low: 155.0,
      median: 182.0,
      currentPrice: 175.0,
    ),
    'AMZN': PriceTarget(
      ticker: 'AMZN',
      high: 240.0,
      low: 175.0,
      median: 205.0,
      currentPrice: 188.0,
    ),
    'NVDA': PriceTarget(
      ticker: 'NVDA',
      high: 160.0,
      low: 95.0,
      median: 130.0,
      currentPrice: 120.0,
    ),
  };

  Future<PriceTarget> fetchPriceTarget(String ticker) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return _mockTargets[ticker] ??
        PriceTarget(
          ticker: ticker,
          high: 150.0,
          low: 100.0,
          median: 125.0,
          currentPrice: 115.0,
        );
  }
}
