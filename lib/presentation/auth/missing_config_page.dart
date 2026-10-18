import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Ditampilkan kalau aplikasi dijalankan tanpa --dart-define Supabase.
class MissingConfigPage extends StatelessWidget {
  const MissingConfigPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.settings_outlined,
                  size: 40, color: AppColors.primary),
              const SizedBox(height: 16),
              Text('Supabase belum dikonfigurasi', style: AppTextStyles.h1),
              const SizedBox(height: 8),
              Text(
                'Jalankan aplikasi dengan menyertakan URL dan anon key project Supabase-mu:',
                style: AppTextStyles.bodyMuted,
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.inputFill,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const SelectableText(
                  'flutter run \\\n'
                  '  --dart-define=SUPABASE_URL=https://xxxx.supabase.co \\\n'
                  '  --dart-define=SUPABASE_ANON_KEY=eyJ...',
                  style: TextStyle(fontFamily: 'monospace', fontSize: 12.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
