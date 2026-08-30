
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/providers/profile_notifier.dart';
import 'change_password_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState
    extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();

    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _fillControllers(
    String firstName,
    String lastName,
    String email,
    String phoneNumber,
  ) {
    if (_firstNameController.text.isEmpty) {
      _firstNameController.text = firstName;
      _lastNameController.text = lastName;
      _emailController.text = email;
      _phoneController.text = phoneNumber;
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await ref
        .read(profileNotifierProvider.notifier)
        .updateProfile(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: _emailController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
        );

    if (!mounted) {
      return;
    }

    final state = ref.read(profileNotifierProvider);

    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Profil güncellenemedi: ${state.error}',
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profil başarıyla güncellendi.'),
      ),
    );
  }

  Future<void> _logout() async {
    final storage = SecureStorageService();

    await storage.clearTokens();

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushNamedAndRemoveUntil(
      '/login',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync =
        ref.watch(profileNotifierProvider);

    final colorScheme =
        Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profil',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: profileAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.error
                        .withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline,
                    size: 42,
                    color: colorScheme.error,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Profil bilgileri yüklenemedi.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$error',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    ref
                        .read(
                          profileNotifierProvider
                              .notifier,
                        )
                        .refreshProfile();
                  },
                  icon: const Icon(
                    Icons.refresh,
                  ),
                  label: const Text(
                    'Tekrar Dene',
                  ),
                ),
              ],
            ),
          ),
        ),
        data: (profile) {
          _fillControllers(
            profile.firstName,
            profile.lastName,
            profile.email,
            profile.phoneNumber,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              20,
              20,
              20,
              32,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                children: [
                  // Profil başlığı
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius:
                          BorderRadius.circular(22),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding:
                              const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.white
                                .withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const CircleAvatar(
                            radius: 42,
                            backgroundColor:
                                Colors.white,
                            child: Icon(
                              Icons.person_outline,
                              size: 46,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        Text(
                          '${profile.firstName} ${profile.lastName}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          profile.email,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    'Kişisel Bilgiler',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'Hesap bilgilerinizi buradan güncelleyebilirsiniz.',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Ad
                  TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'Ad',
                      prefixIcon: Icon(
                        Icons.person_outline,
                      ),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'Ad alanı boş bırakılamaz.';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Soyad
                  TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Soyad',
                      prefixIcon: Icon(
                        Icons.badge_outlined,
                      ),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'Soyad alanı boş bırakılamaz.';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // E-posta
                  TextFormField(
                    controller: _emailController,
                    keyboardType:
                        TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'E-posta',
                      prefixIcon: Icon(
                        Icons.email_outlined,
                      ),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'E-posta alanı boş bırakılamaz.';
                      }

                      if (!value.contains('@')) {
                        return 'Geçerli bir e-posta girin.';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Telefon
                  TextFormField(
                    controller: _phoneController,
                    keyboardType:
                        TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Telefon',
                      prefixIcon: Icon(
                        Icons.phone_outlined,
                      ),
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Güncelle
                  SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed:
                          profileAsync.isLoading
                              ? null
                              : _updateProfile,
                      icon: const Icon(
                        Icons.save_outlined,
                      ),
                      label: const Text(
                        'Bilgileri Güncelle',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    'Hesap Güvenliği',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Şifre değiştir
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              const ChangePasswordScreen(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.lock_outline,
                    ),
                    label: const Text(
                      'Şifre Değiştir',
                    ),
                    style: OutlinedButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 15,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Çıkış
                  OutlinedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(
                      Icons.logout,
                    ),
                    label: const Text(
                      'Çıkış Yap',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor:
                          colorScheme.error,
                      side: BorderSide(
                        color: colorScheme.error
                            .withValues(alpha: 0.5),
                      ),
                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

