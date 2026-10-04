import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/or_divider.dart';
import '../../shell/main_shell.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key, required this.onLoginTap});

  final VoidCallback onLoginTap;

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  void _submit() {
    // TODO: ganti dengan Supabase Authentication (sign up).
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainShell()),
    );
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
        const AppTextField(label: 'Username', hint: 'username', prefixIcon: Icons.person_outline),
        const SizedBox(height: 16),
        const AppTextField(label: 'Email', hint: 'nama@email.com', prefixIcon: Icons.mail_outline),
        const SizedBox(height: 16),
        const AppTextField(
          label: 'Kata Sandi',
          hint: '••••••••',
          prefixIcon: Icons.lock_outline,
          obscureText: true,
        ),
        const SizedBox(height: 16),
        const AppTextField(
          label: 'Ulangi Kata Sandi',
          hint: '••••••••',
          prefixIcon: Icons.lock_outline,
          obscureText: true,
        ),
        const SizedBox(height: 20),
        AppButton(label: 'Daftar Sekarang', icon: Icons.arrow_forward, onPressed: _submit),
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
