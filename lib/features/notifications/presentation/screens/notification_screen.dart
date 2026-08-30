
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/notification_provider.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() =>
      _NotificationScreenState();
}

class _NotificationScreenState
    extends ConsumerState<NotificationScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(
      () => ref
          .read(notificationProvider.notifier)
          .fetchNotifications(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notificationsState =
        ref.watch(notificationProvider);

    final colorScheme =
        Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bildirimler',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: notificationsState.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: colorScheme.error,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Bildirimler yüklenemedi.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$error',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    ref
                        .read(notificationProvider.notifier)
                        .fetchNotifications();
                  },
                  child: const Text('Tekrar Dene'),
                ),
              ],
            ),
          ),
        ),
        data: (notifications) {
          if (notifications.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: colorScheme.primary
                            .withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.notifications_none_outlined,
                        size: 48,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Henüz bildiriminiz yok.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hesap hareketleri ve önemli '
                      'bilgilendirmeler burada görünecek.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () {
              return ref
                  .read(notificationProvider.notifier)
                  .fetchNotifications();
            },
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                16,
                16,
                16,
                32,
              ),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification =
                    notifications[index];

                final isUnread =
                    !notification.isRead;

                return Card(
                  margin: const EdgeInsets.only(
                    bottom: 12,
                  ),
                  elevation: isUnread ? 2 : 1,
                  child: InkWell(
                    borderRadius:
                        BorderRadius.circular(12),
                    onTap: () async {
                      if (!notification.isRead) {
                        await ref
                            .read(
                              notificationProvider
                                  .notifier,
                            )
                            .markAsRead(
                              notification.id,
                            );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: isUnread
                                  ? colorScheme.primary
                                      .withValues(
                                      alpha: 0.10,
                                    )
                                  : Colors.grey
                                      .withValues(
                                      alpha: 0.10,
                                    ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isUnread
                                  ? Icons
                                      .notifications_active_outlined
                                  : Icons
                                      .notifications_none_outlined,
                              color: isUnread
                                  ? colorScheme.primary
                                  : Colors.grey.shade600,
                              size: 23,
                            ),
                          ),

                          const SizedBox(width: 14),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        notification.title,
                                        maxLines: 2,
                                        overflow:
                                            TextOverflow
                                                .ellipsis,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: isUnread
                                              ? FontWeight.bold
                                              : FontWeight.w600,
                                        ),
                                      ),
                                    ),

                                    if (isUnread) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        width: 8,
                                        height: 8,
                                        margin:
                                            const EdgeInsets
                                                .only(
                                          top: 6,
                                        ),
                                        decoration:
                                            BoxDecoration(
                                          color: colorScheme
                                              .primary,
                                          shape:
                                              BoxShape.circle,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),

                                const SizedBox(height: 6),

                                Text(
                                  notification.message,
                                  style: TextStyle(
                                    fontSize: 14,
                                    height: 1.4,
                                    color: isUnread
                                        ? null
                                        : Colors
                                            .grey
                                            .shade600,
                                  ),
                                ),

                                if (isUnread) ...[
                                  const SizedBox(height: 10),
                                  Text(
                                    'Okunmadı',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight:
                                          FontWeight.w600,
                                      color:
                                          colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

