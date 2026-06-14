import 'dart:convert';

import 'package:openai_dart/openai_dart.dart';

import '../config/api_config.dart';
import '../models/extracted_metric.dart';

class OpenAiService {
  OpenAiService({OpenAIClient? client})
      : _client = client ??
            OpenAIClient(apiKey: ApiConfig.openAiApiKey);

  final OpenAIClient _client;

  static const _metricSchema = {
    'type': 'object',
    'properties': {
      'metric_name': {
        'type': 'string',
        'description': 'Short name of the financial metric (e.g. Q3 Revenue)',
      },
      'metric_value': {
        'type': 'number',
        'description': 'Numeric value of the metric if applicable, else 0',
      },
      'metric_context': {
        'type': 'string',
        'description':
            'One-line summary of the metric for display (e.g. Apple Q3 Revenue up 5%)',
      },
      'sentiment_reasoning': {
        'type': 'string',
        'description': 'Brief explanation of the baseline sentiment assessment',
      },
      'baseline_sentiment': {
        'type': 'number',
        'description':
            'Baseline sentiment score from -1.0 (bearish) to 1.0 (bullish)',
      },
    },
    'required': [
      'metric_name',
      'metric_value',
      'metric_context',
      'sentiment_reasoning',
      'baseline_sentiment',
    ],
    'additionalProperties': false,
  };

  Future<ExtractedMetric> extractMetric({
    required String ticker,
    required String articleTitle,
    required String articleText,
  }) async {
    if (!ApiConfig.hasOpenAiKey) {
      return _mockExtraction(ticker, articleTitle, articleText);
    }

    final response = await _client.createChatCompletion(
      request: CreateChatCompletionRequest(
        model: ChatCompletionModel.model(ChatCompletionModels.gpt4oMini),
        temperature: 0.2,
        messages: [
          ChatCompletionMessage.system(
            content:
                'You are a financial analyst. Extract the single most impactful '
                'financial metric from the news article for stock $ticker. '
                'Assess baseline sentiment on a scale from -1.0 (bearish) to 1.0 (bullish).',
          ),
          ChatCompletionMessage.user(
            content: ChatCompletionUserMessageContent.string(
              'Title: $articleTitle\n\nArticle:\n$articleText',
            ),
          ),
        ],
        responseFormat: ResponseFormat.jsonSchema(
          jsonSchema: JsonSchemaObject(
            name: 'financial_metric',
            description: 'Extracted financial metric and baseline sentiment',
            strict: true,
            schema: _metricSchema,
          ),
        ),
      ),
    );

    final content = response.choices.first.message.content;
    if (content == null || content.isEmpty) {
      throw Exception('OpenAI returned empty content');
    }

    final json = jsonDecode(content) as Map<String, dynamic>;
    final metric = ExtractedMetric.fromJson(json);
    return _clampSentiment(metric);
  }

  ExtractedMetric _mockExtraction(
    String ticker,
    String articleTitle,
    String articleText,
  ) {
    final isPositive = articleText.toLowerCase().contains('up') ||
        articleText.toLowerCase().contains('beat') ||
        articleText.toLowerCase().contains('growth');

    return ExtractedMetric(
      metricName: 'Revenue Growth',
      metricValue: isPositive ? 5.2 : -2.1,
      metricContext: '$ticker: ${articleTitle.split(' ').take(6).join(' ')}',
      sentimentReasoning: isPositive
          ? 'Article highlights positive revenue momentum.'
          : 'Article signals weaker-than-expected performance.',
      baselineSentiment: isPositive ? 0.45 : -0.35,
    );
  }

  ExtractedMetric _clampSentiment(ExtractedMetric metric) {
    final clamped = metric.baselineSentiment.clamp(-1.0, 1.0);
    if (clamped == metric.baselineSentiment) return metric;
    return ExtractedMetric(
      metricName: metric.metricName,
      metricValue: metric.metricValue,
      metricContext: metric.metricContext,
      sentimentReasoning: metric.sentimentReasoning,
      baselineSentiment: clamped,
    );
  }
}
