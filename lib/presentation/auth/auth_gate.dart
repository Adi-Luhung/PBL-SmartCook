import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/services/profile_photo_service.dart';
import '../shell/main_shell.dart';

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
      _lastUserId = userId;
      ProfilePhotoService.instance.loadForUser(userId);
    } else if (userId == null && _lastUserId != null) {
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
        return const MainShell();
      },
    );
  }
}
