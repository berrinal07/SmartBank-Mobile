import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/account_response.dart';
import '../../domain/providers/account_provider.dart';

class AccountDetailScreen extends ConsumerWidget {
  final String accountId;

  const AccountDetailScreen({
    super.key,
    required this.accountId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hesap Detayı'),
      ),
      body: FutureBuilder<AccountResponse>(
        future: ref
            .read(accountServiceProvider)
            .getAccountById(accountId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Hesap detayları yüklenemedi: ${snapshot.error}',
              ),
            );
          }

          final account = snapshot.data;

          if (account == null) {
            return const Center(
              child: Text(
                'Hesap bulunamadı.',
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hesap Türü',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        account.accountType.name == 'checking'
                            ? 'Vadesiz Hesap'
                            : 'Vadeli Hesap',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              _InfoCard(
                title: 'Hesap Numarası',
                value: account.accountNumber,
              ),

              _InfoCard(
                title: 'Bakiye',
                value:
                    '${account.balance.toStringAsFixed(2)} ₺',
              ),

             if (account.accountType.name == 'term') ...[
  _InfoCard(
    title: 'Faiz Oranı',
    value: '${account.interestRate}%',
  ),

  _InfoCard(
    title: 'Vade Tarihi',
    value: account.maturityDate != null
        ? _formatDate(account.maturityDate!)
        : 'Belirtilmiyor',
  ),
],

              _InfoCard(
                title: 'Oluşturulma Tarihi',
                value: _formatDate(account.createdAt),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year}';
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;

  const _InfoCard({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(title),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}