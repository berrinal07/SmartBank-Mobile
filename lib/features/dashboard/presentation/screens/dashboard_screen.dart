
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../accounts/domain/models/account_type.dart';
import '../../../accounts/domain/providers/account_notifier.dart';
import '../../../accounts/presentation/screens/accounts_screen.dart';
import '../../../notifications/presentation/screens/notification_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../transactions/presentation/screens/transactions_screen.dart';
import '../../../transfers/presentation/screens/transfer_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountNotifierProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SmartBank',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Profil',
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ProfileScreen(),
                ),
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
                  'Hesap bilgileri yüklenemedi.',
                  textAlign: TextAlign.center,
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
                        .read(accountNotifierProvider.notifier)
                        .refreshAccounts();
                  },
                  child: const Text('Tekrar Dene'),
                ),
              ],
            ),
          ),
        ),
        data: (accounts) {
          final totalBalance = accounts.fold<double>(
            0,
            (sum, account) => sum + account.balance,
          );

          return RefreshIndicator(
            onRefresh: () {
              return ref
                  .read(accountNotifierProvider.notifier)
                  .refreshAccounts();
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                20,
                20,
                20,
                32,
              ),
              children: [
                const Text(
                  'Hoş Geldiniz 👋',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'Finansal durumunuzu buradan yönetebilirsiniz.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),

                const SizedBox(height: 24),

                // Toplam bakiye kartı
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(
                                alpha: 0.15,
                              ),
                              borderRadius:
                                  BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet_outlined,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Toplam Bakiye',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      Text(
                        '${totalBalance.toStringAsFixed(2)} ₺',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        '${accounts.length} hesabınız bulunuyor',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // Hesaplarım başlığı
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Hesaplarım',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                const AccountsScreen(),
                          ),
                        );
                      },
                      child: const Text('Tümünü Gör'),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                if (accounts.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Icon(
                            Icons.account_balance_wallet_outlined,
                            size: 40,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Henüz hesabınız bulunmuyor.',
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...accounts.take(3).map(
                    (account) {
                      final isChecking =
                          account.accountType ==
                              AccountType.checking;

                      return Card(
                        margin:
                            const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          leading: CircleAvatar(
                            backgroundColor:
                                colorScheme.primary
                                    .withValues(alpha: 0.1),
                            child: Icon(
  isChecking
      ? Icons.account_balance_wallet_outlined
      : Icons.lock_clock_outlined,
  color: colorScheme.primary,
),
                          ),
                          title: Text(
                            isChecking
                                ? 'Vadesiz Hesap'
                                : 'Vadeli Hesap',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            '**** ${account.accountNumber.substring(account.accountNumber.length - 4)}',
                          ),
                          trailing: Text(
                            '${account.balance.toStringAsFixed(2)} ₺',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                const SizedBox(height: 18),

                const Text(
                  'Hızlı İşlemler',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _QuickActionButton(
                        icon: Icons.swap_horiz,
                        title: 'Para Transferi',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  const TransferScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _QuickActionButton(
                        icon: Icons.receipt_long_outlined,
                        title: 'İşlemler',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  const TransactionsScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
  children: [
    Expanded(
      child: _QuickActionButton(
        icon: Icons.notifications_none,
        title: 'Bildirimler',
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  const NotificationScreen(),
            ),
          );
        },
      ),
    ),
  ],
),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 8,
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(
                    alpha: 0.08,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 26,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

