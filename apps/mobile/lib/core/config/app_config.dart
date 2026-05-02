class AppConfig {
  static const String env = String.fromEnvironment('ENV', defaultValue: 'dev');

  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://sinapsek-api-demo-dngwvvzdjq-uc.a.run.app',
  );

  static const String apiBase = '$apiUrl/api/v1';

  static bool get isDev => env == 'dev';
  static bool get isDemo => env == 'demo';
  static bool get isProd => env == 'prod';
}
