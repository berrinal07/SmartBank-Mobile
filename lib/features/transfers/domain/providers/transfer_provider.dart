import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client_provider.dart';
import '../../data/services/transfer_service.dart';

final transferServiceProvider = Provider<TransferService>((ref) {
  return TransferService(
    apiClient: ref.read(apiClientProvider),
  );
});