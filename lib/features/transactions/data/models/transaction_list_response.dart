
import 'transaction_response.dart';

class TransactionListResponse {
  final List<TransactionResponse> items;
  final int page;
  final int pageSize;
  final int totalCount;
  final int totalPages;

  const TransactionListResponse({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
  });

  factory TransactionListResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return TransactionListResponse(
      items: (json['items'] as List<dynamic>)
          .map(
            (item) => TransactionResponse.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
      page: json['page'] as int,
      pageSize: json['pageSize'] as int,
      totalCount: json['totalCount'] as int,
      totalPages: json['totalPages'] as int,
    );
  }
}

