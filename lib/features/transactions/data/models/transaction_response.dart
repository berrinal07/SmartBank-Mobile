

class TransactionResponse {
  final String id;
  final String accountId;
  final double amount;
  final String transactionType;
  final String? description;
  final String? relatedAccountId;
  final DateTime createdAt;

  const TransactionResponse({
    required this.id,
    required this.accountId,
    required this.amount,
    required this.transactionType,
    this.description,
    this.relatedAccountId,
    required this.createdAt,
  });

  factory TransactionResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return TransactionResponse(
      id: json['id'] as String,
      accountId: json['accountId'] as String,
      amount: (json['amount'] as num).toDouble(),
      transactionType:
          json['transactionType'].toString(),
      description:
          json['description'] as String?,
      relatedAccountId:
          json['relatedAccountId'] as String?,
      createdAt:
          DateTime.parse(json['createdAt'] as String),
    );
  }
}

