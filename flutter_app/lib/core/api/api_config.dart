class ApiConfig {
  static final String baseUrl = _normalizeBaseUrl(
    const String.fromEnvironment(
      'MOLT_API_BASE_URL',
      defaultValue: 'http://localhost:3000',
    ),
  );

  static String _normalizeBaseUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.endsWith('/api')) {
      return trimmed;
    }
    if (trimmed.endsWith('/')) {
      return '${trimmed}api';
    }
    return '$trimmed/api';
  }
}
