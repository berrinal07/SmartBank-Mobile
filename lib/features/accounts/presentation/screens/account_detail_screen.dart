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
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 24,
              child: Icon(
                account.accountType.name == 'checking'
                    ? Icons.account_balance_wallet_outlined
                    : Icons.lock_clock_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account.accountType.name == 'checking'
                      ? 'Vadesiz Hesap'
                      : 'Vadeli Hesap',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Hesap No: ${account.accountNumber}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 28),

        Text(
          'Bakiye',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          '${account.balance.toStringAsFixed(2)} ₺',
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  ),
),

              const SizedBox(height: 16),

              

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
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(width: 16),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}