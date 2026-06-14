class ExtractedMetric {
  const ExtractedMetric({
    required this.metricName,
    required this.metricValue,
    required this.metricContext,
    required this.sentimentReasoning,
    required this.baselineSentiment,
  });

  final String metricName;
  final double metricValue;
  final String metricContext;
  final String sentimentReasoning;
  final double baselineSentiment;

  factory ExtractedMetric.fromJson(Map<String, dynamic> json) {
    return ExtractedMetric(
      metricName: json['metric_name'] as String,
      metricValue: (json['metric_value'] as num).toDouble(),
      metricContext: json['metric_context'] as String,
      sentimentReasoning: json['sentiment_reasoning'] as String,
      baselineSentiment: (json['baseline_sentiment'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'metric_name': metricName,
        'metric_value': metricValue,
        'metric_context': metricContext,
        'sentiment_reasoning': sentimentReasoning,
        'baseline_sentiment': baselineSentiment,
      };

  String get displayLabel => '$metricName: $metricContext';
}
