import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:smartbank_mobile/core/network/api_client_provider.dart';
import '../../data/notification_service.dart';
import '../../domain/models/notification_response.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final apiClient = ref.read(apiClientProvider);

  return NotificationService(apiClient.dio);
});

final notificationProvider =
    AsyncNotifierProvider<NotificationNotifier, List<NotificationResponse>>(
  NotificationNotifier.new,
);

final unreadNotificationCountProvider =
    FutureProvider<int>((ref) async {
  final service = ref.read(notificationServiceProvider);

  return service.getUnreadCount();
});

class NotificationNotifier
    extends AsyncNotifier<List<NotificationResponse>> {
  @override
  Future<List<NotificationResponse>> build() async {
    final service = ref.read(notificationServiceProvider);

    return service.getNotifications();
  }

  Future<void> fetchNotifications() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final service = ref.read(notificationServiceProvider);

      return service.getNotifications();
    });
  }

  Future<void> markAsRead(String notificationId) async {
    final service = ref.read(notificationServiceProvider);

    await service.markAsRead(notificationId);

    await fetchNotifications();

    ref.invalidate(unreadNotificationCountProvider);
  }
}