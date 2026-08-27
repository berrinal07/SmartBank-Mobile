import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/create_account_request.dart';
import '../../domain/models/account_type.dart';
import '../../domain/providers/account_provider.dart';

class CreateAccountScreen extends ConsumerStatefulWidget {
  const CreateAccountScreen({super.key});

  @override
ConsumerState<CreateAccountScreen> createState() =>
    _CreateAccountScreenState();
}

class _CreateAccountScreenState
    extends ConsumerState<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();

  AccountType _selectedAccountType = AccountType.checking;

  final _initialBalanceController = TextEditingController();

  @override
  void dispose() {
    _initialBalanceController.dispose();
    super.dispose();
  }

 Future<void> _createAccount() async {
  if (!_formKey.currentState!.validate()) {
    return;
  }

  final initialBalance =
      double.parse(_initialBalanceController.text);

  try {
    await ref.read(accountServiceProvider).createAccount(
          CreateAccountRequest(
            accountType: _selectedAccountType,
            initialBalance: initialBalance,
          ),
        );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Hesap başarıyla oluşturuldu.'),
      ),
    );

    Navigator.of(context).pop(true);
  } catch (e, stackTrace) {
  debugPrint('HESAP OLUŞTURMA HATASI: $e');
  debugPrint('STACK TRACE: $stackTrace');

  if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        'Hesap oluşturulamadı: $e',
      ),
    ),
  );
}
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Hesap Aç'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Hesap Tipi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              DropdownButtonFormField<AccountType>(
                initialValue: _selectedAccountType,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: AccountType.values.map((type) {
                  return DropdownMenuItem<AccountType>(
                    value: type,
                    child: Text(
                      type == AccountType.checking
                          ? 'Vadesiz Hesap'
                          : 'Vadeli Hesap',
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) return;

                  setState(() {
                    _selectedAccountType = value;
                  });
                },
              ),

              const SizedBox(height: 24),

              const Text(
                'Başlangıç Bakiyesi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: _initialBalanceController,
                keyboardType:
                    const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Örneğin 1000',
                  suffixText: '₺',
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Başlangıç bakiyesi girin.';
                  }

                  final balance =
                      double.tryParse(value);

                  if (balance == null) {
                    return 'Geçerli bir tutar girin.';
                  }

                  if (balance < 0) {
                    return 'Bakiye negatif olamaz.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _createAccount,
                  child: const Text(
                    'Hesap Oluştur',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}