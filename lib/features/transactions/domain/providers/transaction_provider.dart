
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client_provider.dart';
import '../../data/services/transaction_service.dart';

final transactionServiceProvider =
    Provider<TransactionService>((ref) {
  return TransactionService(
    apiClient: ref.read(apiClientProvider),
  );
});

