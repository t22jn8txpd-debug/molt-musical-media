import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/models/post.dart';

class FeedService {
  FeedService(this._client);

  final ApiClient _client;

  Future<List<Post>> fetchFeed() async {
    final response = await _client.dio.get(ApiEndpoints.feed);
    final data = response.data;
    if (data is List) {
      return data.whereType<Map<String, dynamic>>().map(Post.fromJson).toList();
    }
    if (data is Map<String, dynamic>) {
      final items = data['items'] ?? data['posts'] ?? data['data'] ?? [];
      if (items is List) {
        return items.whereType<Map<String, dynamic>>().map(Post.fromJson).toList();
      }
    }
    return [];
  }
}
