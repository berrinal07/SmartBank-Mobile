import '../../domain/models/account_type.dart';

class AccountResponse {
  final String id;
  final String accountNumber;
  final AccountType accountType;
  final double balance;
  final double interestRate;
  final DateTime? maturityDate;
  final DateTime createdAt;

  const AccountResponse({
    required this.id,
    required this.accountNumber,
    required this.accountType,
    required this.balance,
    required this.interestRate,
    required this.maturityDate,
    required this.createdAt,
  });

  factory AccountResponse.fromJson(Map<String, dynamic> json) {
    return AccountResponse(
      id: json['id'] as String,
      accountNumber: json['accountNumber'] as String,
      accountType: (json['accountType'] as int) == 1
    ? AccountType.checking
    : AccountType.term,
      balance: (json['balance'] as num).toDouble(),
      interestRate: (json['interestRate'] as num).toDouble(),
      maturityDate: json['maturityDate'] != null
          ? DateTime.parse(json['maturityDate'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}