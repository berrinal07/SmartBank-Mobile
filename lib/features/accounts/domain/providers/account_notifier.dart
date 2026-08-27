import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/account_summary_response.dart';
import '../../data/services/account_service.dart';
import 'account_provider.dart';

class AccountNotifier
    extends AsyncNotifier<List<AccountSummaryResponse>> {
  AccountService get _accountService =>
      ref.read(accountServiceProvider);

  @override
  Future<List<AccountSummaryResponse>> build() async {
    return _accountService.getAccounts();
  }

  Future<void> refreshAccounts() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
      () => _accountService.getAccounts(),
    );
  }

}

final accountNotifierProvider = AsyncNotifierProvider<
    AccountNotifier,
    List<AccountSummaryResponse>>(
  AccountNotifier.new,
);