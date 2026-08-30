import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/update_password_request.dart';
import '../../data/models/update_profile_request.dart';
import '../../data/models/user_profile_response.dart';
import '../../data/services/profile_service.dart';
import 'profile_provider.dart';

class ProfileNotifier
    extends AsyncNotifier<UserProfileResponse> {
  ProfileService get _profileService =>
      ref.read(profileServiceProvider);

  @override
  Future<UserProfileResponse> build() async {
    return _profileService.getProfile();
  }

  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
  }) async {
    final request = UpdateProfileRequest(
      firstName: firstName,
      lastName: lastName,
      email: email,
      phoneNumber: phoneNumber,
    );

    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      return _profileService.updateProfile(request);
    });
  }

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final request = UpdatePasswordRequest(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );

    await _profileService.updatePassword(request);
  }

  Future<void> refreshProfile() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      return _profileService.getProfile();
    });
  }
}

final profileNotifierProvider =
    AsyncNotifierProvider<
        ProfileNotifier,
        UserProfileResponse>(
  ProfileNotifier.new,
);