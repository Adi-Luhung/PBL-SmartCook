import 'package:flutter/material.dart';

import '../../core/theme/app_text_styles.dart';
import '../auth/auth_gate.dart';

class _LetterAnimation {
  const _LetterAnimation({
    required this.fade,
    required this.slide,
    required this.scale,
  });

  final Animation<double> fade;
  final Animation<double> slide;
  final Animation<double> scale;
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _textController;
  late final List<_LetterAnimation> _letterAnimations;

  static const String _firstWord = 'Smart';
  static const String _secondWord = 'Cook';

  // Warna hijau khas SmartCook
  static const Color _greenColor = Color(0xFF084E38);

  @override
  void initState() {
    super.initState();

    // Controller untuk animasi huruf demi huruf
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    // Menghitung stagger animasi per huruf
    final totalLetters = _firstWord.length + _secondWord.length;
    _letterAnimations = List.generate(totalLetters, (index) {
      final double start = (index * 0.07).clamp(0.0, 0.7);
      final double end = (start + 0.30).clamp(0.0, 1.0);

      return _LetterAnimation(
        fade: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _textController,
            curve: Interval(start, end, curve: Curves.easeOut),
          ),
        ),
        slide: Tween<double>(begin: 28.0, end: 0.0).animate(
          CurvedAnimation(
            parent: _textController,
            curve: Interval(start, end, curve: Curves.easeOutCubic),
          ),
        ),
        scale: Tween<double>(begin: 0.6, end: 1.0).animate(
          CurvedAnimation(
            parent: _textController,
            curve: Interval(start, end, curve: Curves.easeOutBack),
          ),
        ),
      );
    });

    _textController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 700), () {
          _navigateToAuth();
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _textController.forward();
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _navigateToAuth() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, animation, secondaryAnimation) => const AuthGate(),
        transitionsBuilder: (_, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  Widget _buildLetter(String char, int index, Color color) {
    final anim = _letterAnimations[index];

    return AnimatedBuilder(
      animation: _textController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, anim.slide.value),
          child: Transform.scale(
            scale: anim.scale.value,
            child: Opacity(
              opacity: anim.fade.value,
              child: Text(
                char,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  color: color,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // "Smart" (Warna Gelap Slate)
            ...List.generate(
              _firstWord.length,
              (i) => _buildLetter(
                _firstWord[i],
                i,
                const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(width: 4),
            // "Cook" (Warna Hijau)
            ...List.generate(
              _secondWord.length,
              (i) => _buildLetter(
                _secondWord[i],
                _firstWord.length + i,
                _greenColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
