
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../../../accounts/domain/providers/account_notifier.dart';
import '../../data/models/transfer_request.dart';
import '../../domain/providers/transfer_provider.dart';

class TransferScreen extends ConsumerStatefulWidget {
  const TransferScreen({super.key});

  @override
  ConsumerState<TransferScreen> createState() =>
      _TransferScreenState();
}

class _TransferScreenState
    extends ConsumerState<TransferScreen> {
  final _formKey = GlobalKey<FormState>();

  final _toAccountController =
      TextEditingController();

  final _amountController =
      TextEditingController();

  final _descriptionController =
      TextEditingController();

  String? _selectedFromAccountNumber;

  bool _isLoading = false;

  @override
  void dispose() {
    _toAccountController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _transfer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedFromAccountNumber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Lütfen gönderen hesabı seçin.',
          ),
        ),
      );

      return;
    }

    final amount =
        double.parse(_amountController.text);

    setState(() {
      _isLoading = true;
    });

    try {
      final request = TransferRequest(
        fromAccountNumber:
            _selectedFromAccountNumber!,
        toAccountNumber:
            _toAccountController.text.trim(),
        amount: amount,
        description:
            _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
      );

      await ref
          .read(transferServiceProvider)
          .transfer(request);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Transfer başarıyla gerçekleştirildi.',
          ),
        ),
      );

      _formKey.currentState!.reset();
      _selectedFromAccountNumber = null;
      _toAccountController.clear();
      _amountController.clear();
      _descriptionController.clear();
    } on DioException catch (e) {
  if (!mounted) return;

  String message = 'Transfer gerçekleştirilemedi.';

  final responseData = e.response?.data;

  if (responseData is Map<String, dynamic> &&
      responseData['message'] != null) {
    message = responseData['message'].toString();
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
    ),
  );
} catch (e) {
  if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        'Transfer sırasında beklenmeyen bir hata oluştu.',
      ),
    ),
  );
}finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync =
        ref.watch(accountNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Para Transferi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'Gönderen Hesap',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              accountsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, stackTrace) => Text(
                  'Hesaplar yüklenemedi: $error',
                ),
                data: (accounts) {
                  if (accounts.isEmpty) {
                    return const Text(
                      'Transfer yapmak için hesabınız bulunmuyor.',
                    );
                  }

                  return DropdownButtonFormField<String>(
                   initialValue: _selectedFromAccountNumber,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Gönderen Hesap',
                    ),
                    items: accounts.map((account) {
                      final accountName =
                          account.accountType.name ==
                                  'checking'
                              ? 'Vadesiz Hesap'
                              : 'Vadeli Hesap';

                      return DropdownMenuItem<String>(
                        value: account.accountNumber,
                        child: Text(
                          '$accountName - '
                          '${account.accountNumber} '
                          '(${account.balance.toStringAsFixed(2)} ₺)',
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedFromAccountNumber =
                            value;
                      });
                    },
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty) {
                        return 'Gönderen hesap seçin.';
                      }

                      return null;
                    },
                  );
                },
              ),

              const SizedBox(height: 24),

              const Text(
                'Alıcı Hesap',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: _toAccountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText:
                      'Alıcının hesap numarası',
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Alıcı hesap numarası girin.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 24),

              const Text(
                'Tutar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Örneğin 500',
                  suffixText: '₺',
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Transfer tutarı girin.';
                  }

                  final amount =
                      double.tryParse(value);

                  if (amount == null) {
                    return 'Geçerli bir tutar girin.';
                  }

                  if (amount <= 0) {
                    return 'Tutar 0\'dan büyük olmalıdır.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 24),

              const Text(
                'Açıklama',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller:
                    _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'İsteğe bağlı',
                ),
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      _isLoading ? null : _transfer,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child:
                              CircularProgressIndicator(),
                        )
                      : const Text(
                          'Transfer Yap',
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

