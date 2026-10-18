import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/or_divider.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key, required this.onLoginTap});

  final VoidCallback onLoginTap;

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  String _translate(String message) {
    final m = message.toLowerCase();
    if (m.contains('already registered')) return 'Email sudah terdaftar.';
    if (m.contains('password should be at least')) {
      return 'Kata sandi minimal 6 karakter.';
    }
    if (m.contains('invalid') && m.contains('email')) {
      return 'Format email tidak valid.';
    }
    return message;
  }

  Future<void> _submit() async {
    final messenger = ScaffoldMessenger.of(context);
    final username = _username.text.trim();
    final email = _email.text.trim();
    final password = _password.text;

    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Semua kolom wajib diisi.');
      return;
    }
    if (password.length < 6) {
      setState(() => _error = 'Kata sandi minimal 6 karakter.');
      return;
    }
    if (password != _confirm.text) {
      setState(() => _error = 'Kata sandi dan pengulangannya tidak sama.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // Baris `profiles` dibuat otomatis oleh trigger di database,
      // memakai `username` sebagai full_name awal.
      final res = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {'username': username},
      );

      if (res.session == null && mounted) {
        // Konfirmasi email aktif di Supabase: belum ada sesi sampai dikonfirmasi.
        widget.onLoginTap();
        messenger.showSnackBar(const SnackBar(
          content: Text('Pendaftaran berhasil. Cek emailmu untuk konfirmasi, lalu masuk.'),
        ));
      }
      // Jika sesi langsung ada, AuthGate otomatis pindah ke MainShell.
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = _translate(e.message));
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Tidak dapat terhubung. Periksa koneksi internet.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Selamat Datang', style: AppTextStyles.h2),
        const SizedBox(height: 4),
        Text(
          'Daftar sekarang untuk mulai eksplorasi resep pintar dari bahan dapurmu.',
          style: AppTextStyles.bodyMuted,
        ),
        const SizedBox(height: 20),
        AppTextField(
          label: 'Username',
          hint: 'username',
          prefixIcon: Icons.person_outline,
          controller: _username,
        ),
        const SizedBox(height: 16),
        AppTextField(
          label: 'Email',
          hint: 'nama@email.com',
          prefixIcon: Icons.mail_outline,
          controller: _email,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        AppTextField(
          label: 'Kata Sandi',
          hint: '••••••••',
          prefixIcon: Icons.lock_outline,
          obscureText: true,
          controller: _password,
        ),
        const SizedBox(height: 16),
        AppTextField(
          label: 'Ulangi Kata Sandi',
          hint: '••••••••',
          prefixIcon: Icons.lock_outline,
          obscureText: true,
          controller: _confirm,
        ),
        const SizedBox(height: 12),
        if (_error != null) ...[
          Text(_error!, style: AppTextStyles.caption.copyWith(color: AppColors.danger)),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 8),
        AppButton(
          label: 'Daftar Sekarang',
          icon: Icons.arrow_forward,
          loading: _loading,
          onPressed: _submit,
        ),
        const SizedBox(height: 20),
        const OrDivider(label: 'ATAU DAFTAR DENGAN'),
        const SizedBox(height: 16),
        AppButton(
          label: 'Lanjutkan dengan Google',
          variant: AppButtonVariant.outline,
          onPressed: () {},
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Sudah memiliki akun? ', style: AppTextStyles.bodyMuted),
            GestureDetector(
              onTap: widget.onLoginTap,
              child: Text('Masuk', style: AppTextStyles.label.copyWith(color: AppColors.primary)),
            ),
          ],
        ),
      ],
    );
  }
}
