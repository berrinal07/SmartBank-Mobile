
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../notifications/presentation/providers/notification_provider.dart';
import '../../../notifications/presentation/screens/notification_screen.dart';
import '../../../transactions/presentation/screens/transactions_screen.dart';
import '../../../transfers/presentation/screens/transfer_screen.dart';
import '../../domain/models/account_type.dart';
import '../../domain/providers/account_notifier.dart';
import 'account_detail_screen.dart';
import 'create_account_screen.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountNotifierProvider);

    final unreadCountAsync =
        ref.watch(unreadNotificationCountProvider);

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Hesaplarım',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            tooltip: 'Para Transferi',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const TransferScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'İşlem Geçmişi',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      const TransactionsScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: Badge(
              label: unreadCountAsync.when(
                data: (count) =>
                    count > 0 ? Text('$count') : null,
                loading: () => null,
                error: (_, _) => null,
              ),
              child: const Icon(
                Icons.notifications_outlined,
              ),
            ),
            tooltip: 'Bildirimler',
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      const NotificationScreen(),
                ),
              );

              ref.invalidate(
                unreadNotificationCountProvider,
              );
            },
          ),
        ],
      ),
      body: accountsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Hesaplar yüklenemedi.',
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
                        .read(
                          accountNotifierProvider
                              .notifier,
                        )
                        .refreshAccounts();
                  },
                  child: const Text('Tekrar Dene'),
                ),
              ],
            ),
          ),
        ),
        data: (accounts) {
          if (accounts.isEmpty) {
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
                        Icons.account_balance_wallet_outlined,
                        size: 48,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Henüz hesabınız bulunmuyor.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Yeni bir hesap oluşturarak '
                      'SmartBank\'i kullanmaya başlayabilirsiniz.',
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

          final totalBalance = accounts.fold<double>(
            0,
            (sum, account) => sum + account.balance,
          );

          return RefreshIndicator(
            onRefresh: () {
              return ref
                  .read(
                    accountNotifierProvider.notifier,
                  )
                  .refreshAccounts();
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                16,
                16,
                16,
                100,
              ),
              children: [
                // Toplam bakiye
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Toplam Bakiye',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${totalBalance.toStringAsFixed(2)} ₺',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${accounts.length} hesap',
                        style: const TextStyle(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'Hesaplarınız',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                ...accounts.map(
                  (account) {
                    final isChecking =
                        account.accountType ==
                            AccountType.checking;

                    final accountNumber =
                        account.accountNumber;

                    final lastFour =
                        accountNumber.length >= 4
                            ? accountNumber.substring(
                                accountNumber.length - 4,
                              )
                            : accountNumber;

                    return Card(
                      margin: const EdgeInsets.only(
                        bottom: 12,
                      ),
                      child: InkWell(
                        borderRadius:
                            BorderRadius.circular(12),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  AccountDetailScreen(
                                accountId: account.id,
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding:
                              const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding:
                                        const EdgeInsets.all(
                                      10,
                                    ),
                                    decoration:
                                        BoxDecoration(
                                      color: colorScheme
                                          .primary
                                          .withValues(
                                        alpha: 0.08,
                                      ),
                                      borderRadius:
                                          BorderRadius
                                              .circular(12),
                                    ),
                                    child: Icon(
  isChecking
      ? Icons.account_balance_wallet_outlined
      : Icons.lock_clock_outlined,
  color: colorScheme.primary,
),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                      children: [
                                        Text(
                                          isChecking
                                              ? 'Vadesiz Hesap'
                                              : 'Vadeli Hesap',
                                          style:
                                              const TextStyle(
                                            fontSize: 16,
                                            fontWeight:
                                                FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 4,
                                        ),
                                        Text(
                                          '**** $lastFour',
                                          style: TextStyle(
                                            color: Colors
                                                .grey
                                                .shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.chevron_right,
                                  ),
                                ],
                              ),

                              const SizedBox(height: 18),

                              Text(
                                'Bakiye',
                                style: TextStyle(
                                  color:
                                      Colors.grey.shade600,
                                  fontSize: 13,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                '${account.balance.toStringAsFixed(2)} ₺',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: () async {
          final result =
              await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  const CreateAccountScreen(),
            ),
          );

          if (result == true) {
            ref
                .read(
                  accountNotifierProvider.notifier,
                )
                .refreshAccounts();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Yeni Hesap'),
      ),
    );
  }
}

