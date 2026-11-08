import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/env.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_notification.dart';
import 'google_logo.dart';

class GoogleSignInButton extends StatefulWidget {
  const GoogleSignInButton({
    super.key,
    required this.label,
    this.onError,
    this.onSuccess,
  });

  final String label;
  final ValueChanged<String>? onError;
  final VoidCallback? onSuccess;

  @override
  State<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton>
    with WidgetsBindingObserver {
  bool _loading = false;
  StreamSubscription<AuthState>? _authSub;
  Timer? _resumeCheckTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (data.session != null && mounted) {
        setState(() => _loading = false);
        widget.onSuccess?.call();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _resumeCheckTimer?.cancel();
    _authSub?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _loading) {
      _resumeCheckTimer?.cancel();
      _resumeCheckTimer = Timer(const Duration(seconds: 2), () {
        if (!mounted) return;
        final currentSession = Supabase.instance.client.auth.currentSession;
        if (currentSession != null) {
          setState(() => _loading = false);
          widget.onSuccess?.call();
        } else {
          setState(() => _loading = false);
        }
      });
    }
  }

  String _translateError(String message) {
    final m = message.toLowerCase();
    if (m.contains('provider is not enabled') ||
        m.contains('unsupported provider') ||
        m.contains('validation_failed')) {
      return 'Provider Google belum diaktifkan di Supabase Dashboard. '
          'Pastikan toggle Google aktif di Authentication -> Providers -> Google '
          'dan Client ID & Secret sudah terisi.';
    }
    if (m.contains('redirect') || m.contains('redirect_uri_mismatch')) {
      return 'Redirect URL belum terdaftar di Supabase Dashboard. '
          'Tambahkan "${Env.authCallbackUrl}" di Authentication -> URL Configuration -> Redirect URLs.';
    }
    if (m.contains('popup_closed') ||
        m.contains('cancelled') ||
        m.contains('canceled')) {
      return 'Proses masuk dengan Google dibatalkan.';
    }
    if (m.contains('network') || m.contains('failed to fetch')) {
      return 'Tidak dapat terhubung ke server. Periksa koneksi internet.';
    }
    return 'Gagal melakukan autentikasi Google: $message';
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _loading = true);

    try {
      final redirectTo = kIsWeb ? null : Env.authCallbackUrl;

      if (mounted) {
        AppNotification.showInfo(
          context,
          'Membuka browser untuk masuk dengan Google...',
        );
      }

      final launched = await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: redirectTo,
        queryParams: const {'prompt': 'select_account'},
      );

      if (!launched && mounted) {
        setState(() => _loading = false);
        const msg = 'Tidak dapat membuka browser untuk autentikasi Google.';
        widget.onError?.call(msg);
        AppNotification.showError(context, msg);
      }
    } on AuthException catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        final msg = _translateError(e.message);
        widget.onError?.call(msg);
        AppNotification.showError(context, msg);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        final msg = _translateError(e.toString());
        widget.onError?.call(msg);
        AppNotification.showError(context, msg);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _loading ? null : _handleGoogleSignIn,
          child: Center(
            child: _loading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF084E38)),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Menghubungkan ke Google...',
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const GoogleLogo(size: 20),
                      const SizedBox(width: 12),
                      Text(
                        widget.label,
                        style: const TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
