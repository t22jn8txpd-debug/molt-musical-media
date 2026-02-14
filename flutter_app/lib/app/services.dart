import '../core/api/api_client.dart';
import '../core/storage/token_store.dart';

class AppServices {
  AppServices({TokenStore? tokenStore, ApiClient? apiClient}) {
    this.tokenStore = tokenStore ?? const TokenStore();
    this.apiClient = apiClient ?? ApiClient(this.tokenStore);
  }

  late final TokenStore tokenStore;
  late final ApiClient apiClient;
}
