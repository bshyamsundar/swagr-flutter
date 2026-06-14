/// API keys and feature flags. Replace placeholders before using live APIs.
class ApiConfig {
  static const String openAiApiKey = String.fromEnvironment(
    'OPENAI_API_KEY',
    defaultValue: '',
  );

  static const String marketauxApiKey = String.fromEnvironment(
    'MARKETAUX_API_KEY',
    defaultValue: '',
  );

  /// When true, uses mock news and price targets instead of live APIs.
  static const bool useMockData = bool.fromEnvironment(
    'USE_MOCK_DATA',
    defaultValue: true,
  );

  static bool get hasOpenAiKey => openAiApiKey.isNotEmpty;
  static bool get hasMarketauxKey => marketauxApiKey.isNotEmpty;
}
