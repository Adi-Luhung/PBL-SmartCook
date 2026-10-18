import 'package:flutter/material.dart';

import 'core/services/profile_photo_service.dart';
import 'core/theme/app_theme.dart';
import 'presentation/auth/auth_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ProfilePhotoService.instance.load();
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
