import '../../domain/models/account_type.dart';

class CreateAccountRequest {
  final AccountType accountType;
  final double initialBalance;

  const CreateAccountRequest({
    required this.accountType,
    required this.initialBalance,
  });

  Map<String, dynamic> toJson() {
    return {
      'accountType': accountType == AccountType.checking ? 1 : 2,
      'initialBalance': initialBalance,
    };
  }
}