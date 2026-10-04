import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'presentation/auth/auth_page.dart';

void main() {
  runApp(const SmartCookApp());
}

class SmartCookApp extends StatelessWidget {
  const SmartCookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartCook',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const AuthPage(),
      
    );
  }
}
