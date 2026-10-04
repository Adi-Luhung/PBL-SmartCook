import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/or_divider.dart';
import '../../shell/main_shell.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key, required this.onRegisterTap});

  final VoidCallback onRegisterTap;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool _rememberMe = false;

  void _submit() {
    // TODO: ganti dengan Supabase Authentication (sign in).
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainShell()),
    );
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
        const AppTextField(label: 'Email', hint: 'nama@email.com', prefixIcon: Icons.mail_outline),
        const SizedBox(height: 16),
        const AppTextField(
          label: 'Kata Sandi',
          hint: '••••••••',
          prefixIcon: Icons.lock_outline,
          obscureText: true,
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
        const SizedBox(height: 4),
        AppButton(label: 'Masuk', icon: Icons.arrow_forward, onPressed: _submit),
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
