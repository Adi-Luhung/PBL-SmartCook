import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/services/profile_photo_service.dart';
import '../shell/main_shell.dart';
import 'auth_page.dart';

/// Memilih layar berdasarkan sesi login: belum login → AuthPage,
/// sudah login → MainShell. Sesi tersimpan, jadi pengguna tidak perlu
/// login ulang saat membuka aplikasi lagi.
///
/// Juga menangani load/clear foto profil saat user login/logout.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  String? _lastUserId;

  void _handleSessionChange(Session? session) {
    final userId = session?.user.id;

    if (userId != null && userId != _lastUserId) {
      // User baru login atau session aktif terdeteksi.
      _lastUserId = userId;
      ProfilePhotoService.instance.loadForUser(userId);
    } else if (userId == null && _lastUserId != null) {
      // User logout.
      _lastUserId = null;
      ProfilePhotoService.instance.clearUser();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Supabase.instance.client.auth;
    return StreamBuilder<AuthState>(
      stream: auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = snapshot.data?.session ?? auth.currentSession;
        _handleSessionChange(session);
        return session == null ? const AuthPage() : const MainShell();
      },
    );
  }
}
