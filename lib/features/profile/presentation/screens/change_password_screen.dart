
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/providers/profile_notifier.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState
    extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final _currentPasswordController =
      TextEditingController();

  final _newPasswordController =
      TextEditingController();

  final _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ref
          .read(profileNotifierProvider.notifier)
          .updatePassword(
            currentPassword:
                _currentPasswordController.text,
            newPassword:
                _newPasswordController.text,
          );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Şifre başarıyla güncellendi.',
          ),
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Şifre güncellenemedi: $e',
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
    final colorScheme =
        Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Şifre Değiştir',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          20,
          24,
          20,
          32,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,
            children: [
              // Üst ikon
              Center(
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: colorScheme.primary
                        .withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock_outline,
                    size: 42,
                    color: colorScheme.primary,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Şifrenizi Değiştirin',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Hesabınızın güvenliği için mevcut '
                'şifrenizi ve yeni şifrenizi girin.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 28),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Şifre Bilgileri',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 18),

                      TextFormField(
                        controller:
                            _currentPasswordController,
                        obscureText:
                            _obscureCurrentPassword,
                        decoration: InputDecoration(
                          labelText: 'Mevcut Şifre',
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                          ),
                          suffixIcon: IconButton(
                            tooltip:
                                _obscureCurrentPassword
                                    ? 'Şifreyi göster'
                                    : 'Şifreyi gizle',
                            icon: Icon(
                              _obscureCurrentPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureCurrentPassword =
                                    !_obscureCurrentPassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty) {
                            return 'Mevcut şifre zorunludur.';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller:
                            _newPasswordController,
                        obscureText:
                            _obscureNewPassword,
                        decoration: InputDecoration(
                          labelText: 'Yeni Şifre',
                          prefixIcon: const Icon(
                            Icons.lock_reset,
                          ),
                          suffixIcon: IconButton(
                            tooltip:
                                _obscureNewPassword
                                    ? 'Şifreyi göster'
                                    : 'Şifreyi gizle',
                            icon: Icon(
                              _obscureNewPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureNewPassword =
                                    !_obscureNewPassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty) {
                            return 'Yeni şifre zorunludur.';
                          }

                          if (value.length < 6) {
                            return 'Şifre en az 6 karakter olmalıdır.';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller:
                            _confirmPasswordController,
                        obscureText:
                            _obscureConfirmPassword,
                        decoration: InputDecoration(
                          labelText: 'Yeni Şifre Tekrar',
                          prefixIcon: const Icon(
                            Icons.lock_reset,
                          ),
                          suffixIcon: IconButton(
                            tooltip:
                                _obscureConfirmPassword
                                    ? 'Şifreyi göster'
                                    : 'Şifreyi gizle',
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty) {
                            return 'Şifre tekrarı zorunludur.';
                          }

                          if (value !=
                              _newPasswordController
                                  .text) {
                            return 'Şifreler eşleşmiyor.';
                          }

                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                height: 54,
                child: ElevatedButton.icon(
                  onPressed:
                      _isLoading
                          ? null
                          : _changePassword,
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
                          Icons.check_circle_outline,
                        ),
                  label: Text(
                    _isLoading
                        ? 'Şifre Güncelleniyor...'
                        : 'Şifreyi Güncelle',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.security_outlined,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Şifrenizi kimseyle paylaşmayın.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
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

