
import 'dart:convert';

import '../../../../core/network/api_client.dart';
import '../../../../core/storage/token_storage.dart';
import '../models/user_model.dart';

class AuthRemoteDataSource {
  final ApiClient apiClient;
  final TokenStorage tokenStorage;

  AuthRemoteDataSource(this.apiClient, this.tokenStorage);

  Future<UserModel> register({
    required String nama,
    required String email,
    required String password,
  }) async {
    final response = await apiClient.post(
      '/auth/register',
      body: {
        'nama': nama,
        'email': email,
        'password': password,
      },
      authenticated: false,
      json: true,
    );

    final data = jsonDecode(response.body)
        as Map<String, dynamic>;

    return UserModel.fromJson(data);
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await apiClient.post(
      '/auth/login',
      body: {
        'username': email,
        'password': password,
      },
      authenticated: false,
    );

    final data = jsonDecode(response.body)
        as Map<String, dynamic>;

    final token = data['access_token'] as String;

    await tokenStorage.saveToken(token);

    return getProfile();
  }

  Future<UserModel> getProfile() async {
    final response = await apiClient.get('/auth/me');

    final data = jsonDecode(response.body)
        as Map<String, dynamic>;

    return UserModel.fromJson(data);
  }

  Future<void> logout() async {
    await tokenStorage.deleteToken();
  }
}
