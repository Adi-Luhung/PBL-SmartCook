import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'reset_password_page.dart';
import 'widgets/login_form.dart';
import 'widgets/register_form.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key, this.initialIsLogin = true});

  final bool initialIsLogin;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  late final PageController _pageController;
  StreamSubscription<AuthState>? _authSub;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIsLogin ? 0 : 1);

    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.passwordRecovery && mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const ResetPasswordPage(),
          ),
        );
        return;
      }
      if (data.session != null && mounted && Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _authSub?.cancel();
    super.dispose();
  }

  void _goToLogin() {
    FocusScope.of(context).unfocus();
    _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOutCubic,
    );
  }

  void _goToRegister() {
    FocusScope.of(context).unfocus();
    _pageController.animateToPage(
      1,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (canPop)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 44,
                        height: 44,
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
                  ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(
                          24,
                          canPop ? 16.0 : 48.0,
                          24,
                          36,
                        ),
                        child: LoginForm(
                          onRegisterTap: _goToRegister,
                        ),
                      ),
                      SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(
                          24,
                          canPop ? 16.0 : 48.0,
                          24,
                          36,
                        ),
                        child: RegisterForm(
                          onLoginTap: _goToLogin,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SmoothAuthBackgroundPainter extends CustomPainter {
  const SmoothAuthBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final basePaint = Paint()..color = const Color(0xFFFAFCFA);
    canvas.drawRect(rect, basePaint);

    final mintPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(1.10, -0.90),
        radius: 1.40,
        colors: [
          const Color(0xFFC7F3DE).withValues(alpha: 0.65),
          const Color(0xFFD6F6E7).withValues(alpha: 0.40),
          const Color(0xFFE5FAF0).withValues(alpha: 0.20),
          const Color(0xFFF3FCF6).withValues(alpha: 0.06),
          const Color(0xFFFAFCFA).withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.35, 0.60, 0.82, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, mintPaint);

    final creamPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(1.10, 0.95),
        radius: 1.30,
        colors: [
          const Color(0xFFFEE8C6).withValues(alpha: 0.65),
          const Color(0xFFFFF0D6).withValues(alpha: 0.40),
          const Color(0xFFFFF6E6).withValues(alpha: 0.18),
          const Color(0xFFFFFBF3).withValues(alpha: 0.05),
          const Color(0xFFFAFCFA).withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.35, 0.60, 0.82, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, creamPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
