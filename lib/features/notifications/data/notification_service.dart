import 'package:dio/dio.dart';

import '../domain/models/notification_response.dart';

class NotificationService {
  final Dio dio;

  NotificationService(this.dio);

  Future<List<NotificationResponse>> getNotifications() async {
    final response = await dio.get('/api/Notification');

    final List<dynamic> data = response.data;

    return data
        .map(
          (json) => NotificationResponse.fromJson(json),
        )
        .toList();
  }

  Future<int> getUnreadCount() async {
    final response =
        await dio.get('/api/Notification/unread-count');

    return response.data['count'];
  }

  Future<void> markAsRead(String notificationId) async {
    await dio.patch(
      '/api/Notification/$notificationId/read',
    );
  }
}