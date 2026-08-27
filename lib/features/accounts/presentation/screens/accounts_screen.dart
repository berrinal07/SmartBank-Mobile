
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/providers/account_notifier.dart';
import 'account_detail_screen.dart';
import 'create_account_screen.dart';
import '../../../transfers/presentation/screens/transfer_screen.dart';
import '../../../transactions/presentation/screens/transactions_screen.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hesaplarım'),
        actions: [
          // Para Transferi
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

          // İşlem Geçmişi
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'İşlem Geçmişi',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const TransactionsScreen(),
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
          child: Text(
            'Hesaplar yüklenemedi: $error',
          ),
        ),
        data: (accounts) {
          if (accounts.isEmpty) {
            return const Center(
              child: Text(
                'Henüz hesabınız bulunmuyor.',
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () {
              return ref
                  .read(accountNotifierProvider.notifier)
                  .refreshAccounts();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: accounts.length,
              itemBuilder: (context, index) {
                final account = accounts[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(
                      account.accountType.name == 'checking'
                          ? 'Vadesiz Hesap'
                          : 'Vadeli Hesap',
                    ),
                    subtitle: Text(
                      'Hesap No: ${account.accountNumber}',
                    ),
                    trailing: Text(
                      '${account.balance.toStringAsFixed(2)} ₺',
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AccountDetailScreen(
                            accountId: account.id,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const CreateAccountScreen(),
            ),
          );

          if (result == true) {
            ref
                .read(accountNotifierProvider.notifier)
                .refreshAccounts();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Yeni Hesap'),
      ),
    );
  }
}

