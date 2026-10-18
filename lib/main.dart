import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/env.dart';
import 'core/theme/app_theme.dart';
import 'presentation/auth/auth_gate.dart';
import 'presentation/auth/missing_config_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Env.isConfigured) {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      publishableKey: Env.supabaseAnonKey,
    );
  }

  runApp(const ProviderScope(child: SmartCookApp()));
}

class SmartCookApp extends StatelessWidget {
  const SmartCookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartCook',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: Env.isConfigured ? const AuthGate() : const MissingConfigPage(),
    );
  }
}
