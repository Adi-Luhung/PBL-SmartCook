import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/env.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_notification.dart';
import 'auth_page.dart';
import 'reset_password_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key, this.initialEmail});

  final String? initialEmail;

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  late final TextEditingController _emailController;
  StreamSubscription<AuthState>? _authSub;
  Timer? _countdownTimer;
  int _remainingCooldownSeconds = 0;
  bool _showCooldownWarning = false;
  bool _emailSent = false;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail ?? '');
    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.passwordRecovery && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const ResetPasswordPage(),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _authSub?.cancel();
    _emailController.dispose();
    super.dispose();
  }

  void _startCooldown(int seconds, {bool showWarning = false}) {
    _countdownTimer?.cancel();
    _remainingCooldownSeconds = seconds;
    _showCooldownWarning = showWarning;

    if (_showCooldownWarning) {
      setState(() {
        _error =
            'Demi keamanan, silakan tunggu $_remainingCooldownSeconds detik sebelum meminta kirim ulang.';
      });
    }

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_remainingCooldownSeconds <= 1) {
        timer.cancel();
        setState(() {
          _remainingCooldownSeconds = 0;
          _showCooldownWarning = false;
          _error = null;
        });
      } else {
        setState(() {
          _remainingCooldownSeconds--;
          if (_showCooldownWarning) {
            _error =
                'Demi keamanan, silakan tunggu $_remainingCooldownSeconds detik sebelum meminta kirim ulang.';
          }
        });
      }
    });
  }

  String _translateError(String message) {
    final m = message.toLowerCase();
    final secondsMatch = RegExp(r'(\d+)\s*second').firstMatch(m);
    if (secondsMatch != null) {
      final seconds = secondsMatch.group(1);
      return 'Demi keamanan, silakan tunggu $seconds detik sebelum meminta kirim ulang.';
    }
    if (m.contains('rate limit') || m.contains('too many requests')) {
      return 'Terlalu banyak permintaan. Silakan tunggu beberapa saat sebelum mencoba lagi.';
    }
    if (m.contains('user not found') || m.contains('email not found')) {
      return 'Alamat email tidak terdaftar di sistem.';
    }
    return message;
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() => _error = 'Alamat email wajib diisi.');
      return;
    }

    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(email)) {
      setState(() => _error = 'Format alamat email tidak valid (contoh: nama@email.com).');
      return;
    }

    if (_remainingCooldownSeconds > 0) {
      _showCooldownWarning = true;
      setState(() {
        _error =
            'Demi keamanan, silakan tunggu $_remainingCooldownSeconds detik sebelum meminta kirim ulang.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final redirectTo = kIsWeb ? null : Env.authCallbackUrl;
      await Supabase.instance.client.auth.resetPasswordForEmail(
        email,
        redirectTo: redirectTo,
      );

      if (mounted) {
        setState(() => _emailSent = true);
        _startCooldown(60, showWarning: false);
        AppNotification.showSuccess(
          context,
          'Tautan pemulihan kata sandi telah dikirim ke email Anda. Silakan buka pesan di emailmu.',
        );
      }
    } on AuthException catch (e) {
      if (mounted) {
        final m = e.message.toLowerCase();
        final secondsMatch = RegExp(r'(\d+)\s*second').firstMatch(m);
        if (secondsMatch != null) {
          final seconds = int.tryParse(secondsMatch.group(1)!) ?? 60;
          _startCooldown(seconds, showWarning: true);
        } else {
          final translated = _translateError(e.message);
          setState(() => _error = translated);
          AppNotification.showError(context, translated);
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Tidak dapat terhubung. Periksa koneksi internet Anda.');
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFCFA),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(
            child: CustomPaint(
              painter: SmoothAuthBackgroundPainter(),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1.2,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x060F172A),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => Navigator.of(context).pop(),
                          child: const Center(
                            child: Icon(
                              Icons.chevron_left_rounded,
                              size: 26,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Lupa',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 33,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.5,
                      height: 1.15,
                    ),
                  ),
                  const Text(
                    'Kata Sandi?',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 33,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF084E38),
                      letterSpacing: -0.5,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Masukkan alamat email Anda yang terdaftar untuk menerima instruksi pemulihan kata sandi.',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF64748B),
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 28),
                  DecoratedBox(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x060F172A),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textAlignVertical: TextAlignVertical.center,
                      style: const TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 14,
                        color: Color(0xFF0F172A),
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Alamat Email',
                        hintStyle: const TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 14,
                          color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.w400,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 15,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: _error != null
                                ? AppColors.danger
                                : const Color(0xFFE2E8F0),
                            width: 1.2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: _error != null
                                ? AppColors.danger
                                : const Color(0xFFE2E8F0),
                            width: 1.2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: _error != null
                                ? AppColors.danger
                                : const Color(0xFF084E38),
                            width: 1.5,
                          ),
                        ),
                        prefixIcon: const SizedBox(
                          width: 46,
                          child: Center(
                            child: Icon(
                              Icons.mail_outline_rounded,
                              size: 20,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 46,
                          maxWidth: 46,
                          minHeight: 50,
                          maxHeight: 50,
                        ),
                      ),
                    ),
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
                  if (_emailSent) ...[
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFD1FAE5)),
                      ),
                      child: const Text(
                        'Silakan buka email Anda dan klik tautan pada pesan untuk membuat kata sandi baru.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 12.5,
                          color: Color(0xFF084E38),
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
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
                          : Text(
                              _emailSent ? 'Kirim Ulang' : 'Lanjutkan',
                              style: const TextStyle(
                                fontFamily: AppTextStyles.fontFamily,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
