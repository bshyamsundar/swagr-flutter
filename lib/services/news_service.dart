import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/news_article.dart';

class NewsService {
  NewsService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _mockArticles = <String, List<Map<String, dynamic>>>{
    'AAPL': [
      {
        'title': 'Apple Q3 Revenue Beats Estimates on Strong iPhone Sales',
        'text':
            'Apple Inc reported third-quarter revenue of \$94.9 billion, up 5% '
            'year-over-year, beating analyst estimates. iPhone revenue grew 6% '
            'driven by demand in emerging markets. Services revenue reached a '
            'record \$24.2 billion.',
      },
      {
        'title': 'Apple Faces Supply Chain Headwinds in China',
        'text':
            'Apple warned of potential margin pressure due to supply chain '
            'constraints in China. Analysts trimmed near-term estimates citing '
            'component shortages and softer Mac demand.',
      },
    ],
    'MSFT': [
      {
        'title': 'Microsoft Azure Revenue Surges 29% in Latest Quarter',
        'text':
            'Microsoft reported Azure and cloud services revenue grew 29%, '
            'exceeding Wall Street expectations. AI Copilot adoption accelerated '
            'across enterprise customers, boosting Office 365 ARPU.',
      },
    ],
    'GOOGL': [
      {
        'title': 'Alphabet Ad Revenue Rebounds on Search Strength',
        'text':
            'Alphabet posted advertising revenue growth of 11%, led by Search '
            'and YouTube. Cloud segment narrowed losses faster than expected, '
            'signaling improving operating leverage.',
      },
    ],
    'AMZN': [
      {
        'title': 'Amazon AWS Growth Slows but Retail Margins Expand',
        'text':
            'Amazon Web Services revenue grew 12%, below consensus. However, '
            'North America retail operating margin expanded to 6.1% on '
            'logistics efficiency gains.',
      },
    ],
    'NVDA': [
      {
        'title': 'NVIDIA Data Center Revenue Hits Record on AI Demand',
        'text':
            'NVIDIA data center revenue surged 154% year-over-year as hyperscalers '
            'ramped GPU purchases for generative AI workloads. Management guided '
            'above consensus for next quarter.',
      },
    ],
  };

  Future<List<NewsArticle>> fetchNewsForTicker(String ticker) async {
    if (ApiConfig.useMockData || !ApiConfig.hasMarketauxKey) {
      return _mockNews(ticker);
    }
    return _fetchFromMarketaux(ticker);
  }

  List<NewsArticle> _mockNews(String ticker) {
    final articles = _mockArticles[ticker] ?? _mockArticles['AAPL']!;
    final now = DateTime.now();

    return List.generate(articles.length, (index) {
      final data = articles[index];
      return NewsArticle(
        id: '${ticker}_mock_$index',
        ticker: ticker,
        title: data['title'] as String,
        url: 'https://example.com/news/$ticker/$index',
        rawText: data['text'] as String,
        publishedAt: now.subtract(Duration(days: index * 2, hours: index * 3)),
      );
    });
  }

  Future<List<NewsArticle>> _fetchFromMarketaux(String ticker) async {
    final uri = Uri.https('api.marketaux.com', '/v1/news/all', {
      'symbols': ticker,
      'filter_entities': 'true',
      'language': 'en',
      'limit': '5',
      'api_token': ApiConfig.marketauxApiKey,
    });

    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Marketaux error: ${response.statusCode}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final data = body['data'] as List<dynamic>? ?? [];

    return data.map((item) {
      final map = item as Map<String, dynamic>;
      return NewsArticle(
        id: map['uuid'] as String,
        ticker: ticker,
        title: map['title'] as String,
        url: map['url'] as String,
        rawText: map['description'] as String? ?? map['snippet'] as String? ?? '',
        publishedAt: DateTime.parse(map['published_at'] as String),
      );
    }).toList();
  }
}
