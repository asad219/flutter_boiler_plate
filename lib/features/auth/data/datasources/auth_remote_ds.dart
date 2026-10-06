import 'dart:developer' as developer;

import 'package:app_boilerplate/core/constants/api_endpoints.dart';
import 'package:app_boilerplate/core/network/api_client.dart';
import 'package:app_boilerplate/features/auth/data/models/login_response_model.dart';
import 'package:app_boilerplate/features/auth/data/models/user_model.dart';

/// Throws [ApiException] on failure.
abstract interface class AuthRemoteDataSource {
  Future<LoginResponseModel> login({
    required String email,
    required String password,
  });

  Future<void> logout();

  Future<UserModel> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<LoginResponseModel> login({
    required String email,
    required String password,
  }) async {
    final json = await _apiClient.post(
      ApiEndpoints.login,
      body: {'email': email, 'password': password},
      requiresAuth: false,
      defaultErrorMessage: 'Login failed',
    );
    return LoginResponseModel.fromJson(json);
  }

  @override
  Future<void> logout() async {
    try {
      await _apiClient.post(
        ApiEndpoints.logout,
        defaultErrorMessage: 'Logout failed',
      );
    } catch (error, stackTrace) {
      developer.log(
        'Server sign-out failed; local session will still be cleared',
        name: 'AuthRemoteDataSource.logout',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    final json = await _apiClient.get(
      ApiEndpoints.currentUser,
      defaultErrorMessage: 'Failed to fetch user profile',
    );

    // Handle user data nested under `user` / `data`, or returned directly.
    final nested = json['user'] ?? json['data'];
    if (nested is Map<String, dynamic>) return UserModel.fromJson(nested);
    return UserModel.fromJson(json);
  }
}
