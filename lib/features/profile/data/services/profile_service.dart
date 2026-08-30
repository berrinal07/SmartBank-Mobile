import '../../../../core/network/api_client.dart';
import '../models/update_password_request.dart';
import '../models/update_profile_request.dart';
import '../models/user_profile_response.dart';

class ProfileService {
  final ApiClient _apiClient;

  ProfileService({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  Future<UserProfileResponse> getProfile() async {
    final response = await _apiClient.dio.get(
      '/api/user/profile',
    );

    return UserProfileResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<UserProfileResponse> updateProfile(
    UpdateProfileRequest request,
  ) async {
    final response = await _apiClient.dio.put(
      '/api/user/profile',
      data: request.toJson(),
    );

    return UserProfileResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<void> updatePassword(
    UpdatePasswordRequest request,
  ) async {
    await _apiClient.dio.put(
      '/api/user/password',
      data: request.toJson(),
    );
  }
}