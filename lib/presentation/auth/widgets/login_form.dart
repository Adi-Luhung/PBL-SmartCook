import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/or_divider.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key, required this.onRegisterTap});

  final VoidCallback onRegisterTap;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _rememberMe = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  String _translate(String message) {
    final m = message.toLowerCase();
    if (m.contains('invalid login credentials')) {
      return 'Email atau kata sandi salah.';
    }
    if (m.contains('email not confirmed')) {
      return 'Email belum dikonfirmasi. Cek kotak masuk emailmu.';
    }
    return message;
  }

  Future<void> _submit() async {
    final email = _email.text.trim();
    final password = _password.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Email dan kata sandi wajib diisi.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await Supabase.instance.client.auth
          .signInWithPassword(email: email, password: password);
      // AuthGate otomatis pindah ke MainShell setelah sesi terbentuk.
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
        Text('Selamat Datang Kembali', style: AppTextStyles.h2),
        const SizedBox(height: 4),
        Text('Masuk untuk mengeksplorasi kreasi dapurmu.', style: AppTextStyles.bodyMuted),
        const SizedBox(height: 20),
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
        const SizedBox(height: 4),
        Row(
          children: [
            Checkbox(
              value: _rememberMe,
              activeColor: AppColors.primary,
              onChanged: (v) => setState(() => _rememberMe = v ?? false),
            ),
            Text('Ingat Saya', style: AppTextStyles.bodyMuted),
            const Spacer(),
            TextButton(
              onPressed: () {},
              child: Text(
                'Lupa Kata Sandi?',
                style: AppTextStyles.label.copyWith(color: AppColors.primary),
              ),
            ),
          ],
        ),
        if (_error != null) ...[
          Text(_error!, style: AppTextStyles.caption.copyWith(color: AppColors.danger)),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 4),
        AppButton(
          label: 'Masuk',
          icon: Icons.arrow_forward,
          loading: _loading,
          onPressed: _submit,
        ),
        const SizedBox(height: 20),
        const OrDivider(label: 'ATAU MASUK DENGAN'),
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
            Text('Belum punya akun? ', style: AppTextStyles.bodyMuted),
            GestureDetector(
              onTap: widget.onRegisterTap,
              child: Text(
                'Daftar Sekarang',
                style: AppTextStyles.label.copyWith(color: AppColors.primary),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
