import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client_provider.dart';
import '../../data/services/account_service.dart';

final accountServiceProvider = Provider<AccountService>((ref) {
  return AccountService(
    apiClient: ref.read(apiClientProvider),
  );
});