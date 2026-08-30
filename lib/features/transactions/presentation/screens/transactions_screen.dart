
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/providers/transaction_notifier.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() =>
      _TransactionsScreenState();
}

class _TransactionsScreenState
    extends ConsumerState<TransactionsScreen> {
  final ScrollController _scrollController =
      ScrollController();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final position = _scrollController.position;

    if (position.pixels >=
        position.maxScrollExtent - 200) {
      ref
          .read(transactionNotifierProvider.notifier)
          .loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsync =
        ref.watch(transactionNotifierProvider);

    final colorScheme =
        Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'İşlem Geçmişi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: transactionsAsync.when(
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
                  'İşlemler yüklenemedi.',
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
                          transactionNotifierProvider
                              .notifier,
                        )
                        .refreshTransactions();
                  },
                  child: const Text('Tekrar Dene'),
                ),
              ],
            ),
          ),
        ),
        data: (transactions) {
          if (transactions.isEmpty) {
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
                        Icons.receipt_long_outlined,
                        size: 48,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Henüz işleminiz bulunmuyor.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Yaptığınız para transferleri ve '
                      'diğer işlemler burada görünecek.',
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
                  .read(
                    transactionNotifierProvider
                        .notifier,
                  )
                  .refreshTransactions();
            },
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(
                16,
                16,
                16,
                32,
              ),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction =
                    transactions[index];

                final isIncoming =
                    transaction.amount >= 0;

                final amountText =
                    '${isIncoming ? '+' : ''}'
                    '${transaction.amount.toStringAsFixed(2)} ₺';

                final description =
                    transaction.description ??
                        'Transfer';

                final localDate =
                    transaction.createdAt.toLocal();

                final dateText =
                    '${localDate.day.toString().padLeft(2, '0')}.'
                    '${localDate.month.toString().padLeft(2, '0')}.'
                    '${localDate.year}';

                final timeText =
                    '${localDate.hour.toString().padLeft(2, '0')}:'
                    '${localDate.minute.toString().padLeft(2, '0')}';

                return Card(
                  margin: const EdgeInsets.only(
                    bottom: 12,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: (isIncoming
                                    ? Colors.green
                                    : Colors.red)
                                .withValues(
                              alpha: 0.10,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isIncoming
                                ? Icons
                                    .arrow_downward_rounded
                                : Icons
                                    .arrow_upward_rounded,
                            color: isIncoming
                                ? Colors.green
                                : Colors.red,
                            size: 22,
                          ),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                description,
                                maxLines: 1,
                                overflow:
                                    TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                '$dateText • $timeText',
                                style: TextStyle(
                                  fontSize: 13,
                                  color:
                                      Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 12),

                        Text(
                          amountText,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isIncoming
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ],
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

