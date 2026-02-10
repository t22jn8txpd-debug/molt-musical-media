import 'package:dio/dio.dart';
import 'package:molt_musical_media/core/api/api_client.dart';
import 'package:molt_musical_media/core/storage/token_store.dart';

class FakeTokenStore extends TokenStore {
  const FakeTokenStore();

  @override
  Future<String?> readToken() async => null;

  @override
  Future<void> writeToken(String token) async {}

  @override
  Future<void> clearToken() async {}
}

class FakeApiClient implements ApiClient {
  FakeApiClient({required Response<dynamic> Function(RequestOptions) onRequest})
      : dio = Dio() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.resolve(onRequest(options));
        },
      ),
    );
  }

  @override
  final Dio dio;
}
