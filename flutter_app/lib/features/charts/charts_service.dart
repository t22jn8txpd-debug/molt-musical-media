import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/models/chart.dart';

class ChartsService {
  ChartsService(this._client);

  final ApiClient _client;

  Future<List<ChartCategory>> fetchCharts() async {
    final response = await _client.dio.get(ApiEndpoints.charts);
    final data = response.data;
    if (data is List) {
      return data.whereType<Map<String, dynamic>>().map(ChartCategory.fromJson).toList();
    }
    if (data is Map<String, dynamic>) {
      final categories = data['categories'] ?? data['charts'] ?? data['data'] ?? [];
      if (categories is List) {
        return categories.whereType<Map<String, dynamic>>().map(ChartCategory.fromJson).toList();
      }
    }
    return [];
  }
}
