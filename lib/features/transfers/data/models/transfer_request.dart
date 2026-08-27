class TransferRequest {
  final String fromAccountNumber;
  final String toAccountNumber;
  final double amount;
  final String? description;

  const TransferRequest({
    required this.fromAccountNumber,
    required this.toAccountNumber,
    required this.amount,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'fromAccountNumber': fromAccountNumber,
      'toAccountNumber': toAccountNumber,
      'amount': amount,
      'description': description,
    };
  }
}