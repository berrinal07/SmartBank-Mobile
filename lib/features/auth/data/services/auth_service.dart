import '../../../../core/network/api_client.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/register_request.dart';
import '../models/register_response.dart';

class AuthService {
  final ApiClient _apiClient;
  final SecureStorageService _storage;

  AuthService({
    required ApiClient apiClient,
    required SecureStorageService storage,
  })  : _apiClient = apiClient,
        _storage = storage;

  Future<LoginResponse> login(LoginRequest request) async {
    final response = await _apiClient.dio.post(
      '/api/auth/login',
      data: request.toJson(),
    );

    final loginResponse =
        LoginResponse.fromJson(response.data);

    await _storage.saveTokens(
      accessToken: loginResponse.accessToken,
      refreshToken: loginResponse.refreshToken,
    );

    return loginResponse;
  }

  Future<RegisterResponse> register(
    RegisterRequest request,
  ) async {
    final response = await _apiClient.dio.post(
      '/api/auth/register',
      data: request.toJson(),
    );

    return RegisterResponse.fromJson(response.data);
  }
}