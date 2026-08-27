import '../../../../core/network/api_client.dart';
import '../models/transfer_request.dart';

class TransferService {
  final ApiClient _apiClient;

  TransferService({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  Future<void> transfer(
    TransferRequest request,
  ) async {
    await _apiClient.dio.post(
      '/api/transfers',
      data: request.toJson(),
    );
  }
}