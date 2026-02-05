import '../core/api/api_client.dart';
import '../core/storage/token_store.dart';

class AppServices {
  AppServices() {
    tokenStore = const TokenStore();
    apiClient = ApiClient(tokenStore);
  }

  late final TokenStore tokenStore;
  late final ApiClient apiClient;
}
