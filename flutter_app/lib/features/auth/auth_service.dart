import 'package:flutter/foundation.dart';

import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/storage/token_store.dart';

class AuthService {
  AuthService(this._client, this._tokenStore);

  final ApiClient _client;
  final TokenStore _tokenStore;

  Future<void> login({required String email, required String password}) async {
    debugPrint('Auth login -> ${ApiEndpoints.login}');
    final response = await _client.dio.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );
    final token = _extractToken(response.data);
    if (token != null) {
      await _tokenStore.writeToken(token);
    }
  }

  Future<void> signup({
    required String username,
    required String email,
    required String password,
  }) async {
    final payload = {'username': username, 'email': email, 'password': password};
    debugPrint('Auth signup -> ${ApiEndpoints.signup} payload=$payload');
    final response = await _client.dio.post(
      ApiEndpoints.signup,
      data: payload,
    );
    final token = _extractToken(response.data);
    if (token != null) {
      await _tokenStore.writeToken(token);
    }
  }

  String? _extractToken(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['token']?.toString() ?? data['accessToken']?.toString();
    }
    return null;
  }
}
