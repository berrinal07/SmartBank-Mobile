import '../../domain/models/account_type.dart';

class AccountSummaryResponse {
  final String id;
  final String accountNumber;
  final AccountType accountType;
  final double balance;

  const AccountSummaryResponse({
    required this.id,
    required this.accountNumber,
    required this.accountType,
    required this.balance,
  });

  factory AccountSummaryResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return AccountSummaryResponse(
      id: json['id'] as String,
      accountNumber: json['accountNumber'] as String,
      accountType: (json['accountType'] as int) == 1
    ? AccountType.checking
    : AccountType.term,
      balance: (json['balance'] as num).toDouble(),
    );
  }
}