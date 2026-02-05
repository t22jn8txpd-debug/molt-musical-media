class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'MOLT_API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );
}
