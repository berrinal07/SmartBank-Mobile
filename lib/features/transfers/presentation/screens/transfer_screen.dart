
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../../../accounts/domain/providers/account_notifier.dart';
import '../../data/models/transfer_request.dart';
import '../../domain/providers/transfer_provider.dart';
import '../../../notifications/presentation/providers/notification_provider.dart';

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

      ref.invalidate(
        unreadNotificationCountProvider,
      );

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

      String message =
          'Transfer gerçekleştirilemedi.';

      final responseData = e.response?.data;

      if (responseData is Map<String, dynamic> &&
          responseData['message'] != null) {
        message =
            responseData['message'].toString();
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
    } finally {
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

    final colorScheme =
        Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Para Transferi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Başlık
              const Text(
                'Para Gönder',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Hesaplarınız arasında ve diğer kullanıcı '
                'hesaplarıyla güvenli bir şekilde para '
                'transferi yapabilirsiniz.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),

              const SizedBox(height: 28),

              // Gönderen hesap
              const Text(
                'Gönderen Hesap',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 10),

              accountsAsync.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child:
                        CircularProgressIndicator(),
                  ),
                ),
                error: (error, stackTrace) =>
                    Container(
                  padding:
                      const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.error
                        .withValues(alpha: 0.08),
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Hesaplar yüklenemedi: $error',
                  ),
                ),
                data: (accounts) {
                  if (accounts.isEmpty) {
                    return Container(
                      padding:
                          const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Transfer yapmak için hesabınız '
                        'bulunmuyor.',
                      ),
                    );
                  }

                  return DropdownButtonFormField<String>(
                    initialValue:
                        _selectedFromAccountNumber,
                    isExpanded: true,
                    decoration:
                        const InputDecoration(
                      labelText: 'Gönderen hesap',
                      prefixIcon: Icon(
                        Icons
                            .account_balance_wallet_outlined,
                      ),
                    ),
                    items: accounts.map((account) {
                      final accountName =
                          account.accountType.name ==
                                  'checking'
                              ? 'Vadesiz Hesap'
                              : 'Vadeli Hesap';

                      final accountNumber =
                          account.accountNumber;

                      final lastFour =
                          accountNumber.length >= 4
                              ? accountNumber.substring(
                                  accountNumber.length - 4,
                                )
                              : accountNumber;

                      return DropdownMenuItem<String>(
                        value:
                            account.accountNumber,
                        child: Text(
                          '$accountName • **** $lastFour • '
                          '${account.balance.toStringAsFixed(2)} ₺',
                          overflow:
                              TextOverflow.ellipsis,
                          maxLines: 1,
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

              const SizedBox(height: 22),

              // Alıcı hesap
              const Text(
                'Alıcı Hesap',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 10),

              TextFormField(
                controller: _toAccountController,
                keyboardType:
                    TextInputType.number,
                decoration:
                    const InputDecoration(
                  labelText: 'Hesap numarası',
                  hintText:
                      'Alıcının hesap numarası',
                  prefixIcon: Icon(
                    Icons.person_outline,
                  ),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Alıcı hesap numarası girin.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 22),

              // Tutar
              const Text(
                'Transfer Tutarı',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 10),

              TextFormField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration:
                    const InputDecoration(
                  labelText: 'Tutar',
                  hintText: 'Örneğin 500',
                  prefixIcon: Icon(
                    Icons.payments_outlined,
                  ),
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

              const SizedBox(height: 22),

              // Açıklama
              const Text(
                'Açıklama',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 10),

              TextFormField(
                controller:
                    _descriptionController,
                maxLines: 3,
                decoration:
                    const InputDecoration(
                  labelText: 'Açıklama',
                  hintText: 'İsteğe bağlı',
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(
                      bottom: 40,
                    ),
                    child: Icon(
                      Icons.notes_outlined,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Transfer butonu
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed:
                      _isLoading ? null : _transfer,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.send_outlined,
                        ),
                  label: Text(
                    _isLoading
                        ? 'Transfer gerçekleştiriliyor...'
                        : 'Transfer Yap',
                    style:
                        const TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Güvenlik bilgisi
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 16,
                    color:
                        Colors.grey.shade600,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Güvenli transfer',
                    style: TextStyle(
                      fontSize: 13,
                      color:
                          Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

