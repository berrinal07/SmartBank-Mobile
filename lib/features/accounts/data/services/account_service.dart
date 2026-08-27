import '../../../../core/network/api_client.dart';
import '../models/account_response.dart';
import '../models/account_summary_response.dart';
import '../models/create_account_request.dart';

class AccountService {
  final ApiClient _apiClient;

  AccountService({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  Future<List<AccountSummaryResponse>> getAccounts() async {
    final response = await _apiClient.dio.get(
      '/api/accounts',
    );

    final data = response.data as List;

    return data
        .map(
          (json) => AccountSummaryResponse.fromJson(
            json as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<AccountResponse> getAccountById(
    String id,
  ) async {
    final response = await _apiClient.dio.get(
      '/api/accounts/$id',
    );

    return AccountResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<AccountResponse> createAccount(
    CreateAccountRequest request,
  ) async {
    final response = await _apiClient.dio.post(
      '/api/accounts',
      data: request.toJson(),
    );

    return AccountResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}