
import '../../../../core/network/api_client.dart';
import '../models/transaction_list_response.dart';

class TransactionService {
  final ApiClient apiClient;

  TransactionService({
    required this.apiClient,
  });

  Future<TransactionListResponse> getTransactions({
    int page = 1,
    int pageSize = 10,
  }) async {
    final response = await apiClient.dio.get(
      '/api/transactions',
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
      },
    );

    return TransactionListResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}
