
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/transaction_response.dart';
import '../../data/services/transaction_service.dart';
import 'transaction_provider.dart';

class TransactionNotifier
    extends AsyncNotifier<List<TransactionResponse>> {
  TransactionService get _transactionService =>
      ref.read(transactionServiceProvider);

  int _currentPage = 1;

  static const int _pageSize = 10;

  bool _hasMore = true;

  @override
  Future<List<TransactionResponse>> build() async {
    _currentPage = 1;
    _hasMore = true;

    final response =
        await _transactionService.getTransactions(
      page: _currentPage,
      pageSize: _pageSize,
    );

    _hasMore = _currentPage < response.totalPages;

    return response.items;
  }

  Future<void> loadMore() async {
    if (!_hasMore || state.isLoading) {
      return;
    }

    final nextPage = _currentPage + 1;

    final response =
        await _transactionService.getTransactions(
      page: nextPage,
      pageSize: _pageSize,
    );

    _currentPage = nextPage;

    _hasMore = _currentPage < response.totalPages;

    final currentItems = state.value ?? [];

    state = AsyncData([
      ...currentItems,
      ...response.items,
    ]);
  }

  Future<void> refreshTransactions() async {
    _currentPage = 1;
    _hasMore = true;

    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final response =
          await _transactionService.getTransactions(
        page: 1,
        pageSize: _pageSize,
      );

      _hasMore = response.page < response.totalPages;

      return response.items;
    });
  }
}

final transactionNotifierProvider =
    AsyncNotifierProvider<
        TransactionNotifier,
        List<TransactionResponse>>(
  TransactionNotifier.new,
);

