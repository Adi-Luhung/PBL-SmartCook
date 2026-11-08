import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'auth_text_field.dart';
import 'google_sign_in_button.dart';

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
  final _passwordFocusNode = FocusNode();

  bool _showPasswordRequirements = false;
  bool _rememberMe = false;
  bool _loading = false;
  String? _error;

  static const _rememberMeKey = 'smartcook_remember_me';
  static const _savedEmailKey = 'smartcook_saved_email';

  @override
  void initState() {
    super.initState();
    _loadRememberedEmail();
    _passwordFocusNode.addListener(() {
      if (_passwordFocusNode.hasFocus && !_showPasswordRequirements) {
        setState(() => _showPasswordRequirements = true);
      }
    });
  }

  Future<void> _loadRememberedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final remember = prefs.getBool(_rememberMeKey) ?? false;
    if (remember) {
      final savedEmail = prefs.getString(_savedEmailKey);
      if (savedEmail != null && mounted) {
        setState(() {
          _rememberMe = true;
          _email.text = savedEmail;
        });
      }
    }
  }

  Future<void> _saveRememberMe(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberMeKey, _rememberMe);
    if (_rememberMe) {
      await prefs.setString(_savedEmailKey, email);
    }
  }

  @override
  void dispose() {
    _passwordFocusNode.dispose();
    _username.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  String _translate(String message) {
    final m = message.toLowerCase();
    if (m.contains('already registered') || m.contains('user already exists')) {
      return 'Email ini sudah terdaftar. Silakan langsung masuk.';
    }
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

    if (username.isEmpty || email.isEmpty || password.isEmpty || _confirm.text.isEmpty) {
      setState(() => _error = 'Semua kolom wajib diisi.');
      return;
    }

    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(email)) {
      setState(() => _error = 'Format alamat email tidak valid (contoh: nama@email.com).');
      return;
    }

    if (password.length < 6) {
      setState(() => _error = 'Kata sandi minimal 6 karakter.');
      return;
    }
    if (!RegExp(r'[A-Z]').hasMatch(password) || !RegExp(r'[0-9]').hasMatch(password)) {
      setState(() => _error = 'Kata sandi harus mengandung kombinasi huruf besar dan angka.');
      return;
    }
    if (password != _confirm.text) {
      setState(() => _error = 'Kata sandi dan ulangi kata sandi tidak cocok.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final res = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {'username': username, 'full_name': username},
      );

      await _saveRememberMe(email);

      if (res.session == null && mounted) {
        widget.onLoginTap();
        messenger.showSnackBar(
          const SnackBar(
            content: Text(
              'Pendaftaran berhasil! Cek emailmu untuk konfirmasi, lalu masuk.',
            ),
            backgroundColor: Color(0xFF084E38),
          ),
        );
      } else if (mounted && Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
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
        const Text(
          'Selamat Datang di',
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
            letterSpacing: -0.5,
            height: 1.15,
          ),
        ),
        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              height: 1.15,
            ),
            children: [
              TextSpan(
                text: 'Smart',
                style: TextStyle(color: Color(0xFF0F172A)),
              ),
              TextSpan(
                text: 'Cook!',
                style: TextStyle(color: Color(0xFF084E38)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Daftar sekarang untuk mulai eksplorasi resep cerdas dan sehat dari bahan dapurmu.',
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 13.5,
            fontWeight: FontWeight.w400,
            color: Color(0xFF64748B),
            height: 1.45,
          ),
        ),
        const SizedBox(height: 24),
        AuthTextField(
          label: 'Nama Pengguna',
          hint: 'budi_santoso',
          prefixIcon: Icons.person_outline_rounded,
          controller: _username,
        ),
        const SizedBox(height: 16),
        AuthTextField(
          label: 'Alamat Email',
          hint: 'nama@gmail.com',
          prefixIcon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
          controller: _email,
        ),
        const SizedBox(height: 16),
        AuthTextField(
          label: 'Kata Sandi',
          hint: '••••••••',
          prefixIcon: Icons.lock_outline_rounded,
          obscureText: true,
          controller: _password,
          focusNode: _passwordFocusNode,
          onTap: () {
            if (!_showPasswordRequirements) {
              setState(() => _showPasswordRequirements = true);
            }
          },
        ),
        if (_showPasswordRequirements) ...[
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Icon(
                Icons.info_outline_rounded,
                size: 14,
                color: Color(0xFF64748B),
              ),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Minimal 6 karakter dengan kombinasi huruf besar dan angka.',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 16),
        AuthTextField(
          label: 'Ulangi Kata Sandi',
          hint: '••••••••',
          prefixIcon: Icons.lock_outline_rounded,
          obscureText: true,
          controller: _confirm,
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Checkbox(
                value: _rememberMe,
                activeColor: const Color(0xFF084E38),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
                onChanged: (v) => setState(() => _rememberMe = v ?? false),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => setState(() => _rememberMe = !_rememberMe),
              child: const Text(
                'Ingat Saya',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF475569),
                ),
              ),
            ),
          ],
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFECACA)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, size: 18, color: AppColors.danger),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _error!,
                    style: const TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 12.5,
                      color: AppColors.danger,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 20),
        Container(
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x38084E38),
                blurRadius: 14,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: _loading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF084E38),
              disabledBackgroundColor: const Color(0xFF084E38).withValues(alpha: 0.6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: _loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Daftar',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: const [
            Expanded(
              child: Divider(color: Color(0xFFE2E8F0), thickness: 1),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'atau daftar dengan',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ),
            Expanded(
              child: Divider(color: Color(0xFFE2E8F0), thickness: 1),
            ),
          ],
        ),
        const SizedBox(height: 18),
        GoogleSignInButton(
          label: 'Daftar dengan Google',
          onError: (err) => setState(() => _error = err),
          onSuccess: () {
            if (mounted && Navigator.canPop(context)) {
              Navigator.of(context).pop();
            }
          },
        ),
        const SizedBox(height: 28),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Sudah punya akun? ',
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 14,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
            GestureDetector(
              onTap: widget.onLoginTap,
              child: const Text(
                'Masuk',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 14,
                  color: Color(0xFF084E38),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
