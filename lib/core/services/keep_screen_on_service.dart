import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// Service terpusat untuk mengelola fitur Keep Screen On (mencegah layar mati otomatis).
///
/// Dirancang khusus untuk skenario membaca resep & panduan memasak agar layar tidak terkunci
/// otomatis saat pengguna sedang sibuk memasak di dapur.
///
/// Fitur:
/// - Reusable & terisolasi dari kode UI.
/// - Logging standar `[KEEP_SCREEN_ON]` untuk mempermudah pemantauan langsung di konsol & logcat.
/// - Bebas race condition berkat sequence tracking (_operationSeq).
/// - Verifikasi nyata status wakelock ke platform (Android/iOS).
/// - Heartbeat berkala untuk memastikan OS Android (MIUI, OneUI, ColorOS) tidak mematikan wakelock.
class KeepScreenOnService {
  KeepScreenOnService._();

  /// Singleton instance
  static final KeepScreenOnService instance = KeepScreenOnService._();

  bool _isRequested = false;
  int _operationSeq = 0;
  Timer? _heartbeatTimer;

  /// Status apakah Keep Screen On sedang aktif diminta oleh aplikasi
  bool get isRequested => _isRequested;

  /// Mengaktifkan Keep Screen On agar layar tetap menyala.
  Future<bool> enable({String? source}) async {
    final currentSeq = ++_operationSeq;
    _isRequested = true;

    final sourceInfo = source != null ? ' ($source)' : '';
    debugPrint('[KEEP_SCREEN_ON] Mengaktifkan wakelock$sourceInfo');

    try {
      await WakelockPlus.enable();

      if (_operationSeq != currentSeq || !_isRequested) {
        return false;
      }

      bool active = await WakelockPlus.enabled;

      // Retry singkat jika platform Android belum selesai menyesuaikan window flag
      if (!active && _isRequested && _operationSeq == currentSeq) {
        await Future.delayed(const Duration(milliseconds: 100));
        if (_isRequested && _operationSeq == currentSeq) {
          await WakelockPlus.enable();
          active = await WakelockPlus.enabled;
        }
      }

      debugPrint('[KEEP_SCREEN_ON] Status wakelock: $active');

      // Mulai heartbeat timer untuk menjaga wakelock tetap aktif di Android OS tertentu
      _startHeartbeat();

      return active;
    } catch (e, stack) {
      debugPrint('[KEEP_SCREEN_ON] Error saat mengaktifkan wakelock: $e\n$stack');
      return false;
    }
  }

  /// Menonaktifkan Keep Screen On dan mengembalikan layar ke pengaturan normal perangkat.
  Future<bool> disable({String? source}) async {
    final currentSeq = ++_operationSeq;
    _isRequested = false;
    _stopHeartbeat();

    final sourceInfo = source != null ? ' ($source)' : '';
    debugPrint('[KEEP_SCREEN_ON] Wakelock dinonaktifkan$sourceInfo');

    try {
      await WakelockPlus.disable();

      if (_operationSeq != currentSeq || _isRequested) {
        return false;
      }

      final active = await WakelockPlus.enabled;
      debugPrint('[KEEP_SCREEN_ON] Status wakelock: $active');
      return !active;
    } catch (e, stack) {
      debugPrint('[KEEP_SCREEN_ON] Error saat menonaktifkan wakelock: $e\n$stack');
      return false;
    }
  }

  /// Memulai timer heartbeat setiap 15 detik untuk memverifikasi dan mempertahankan
  /// status wakelock selama halaman panduan aktif.
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 15), (_) async {
      if (!_isRequested) {
        _stopHeartbeat();
        return;
      }
      try {
        final active = await WakelockPlus.enabled;
        if (!active && _isRequested) {
          debugPrint('[KEEP_SCREEN_ON] Heartbeat mendeteksi wakelock terlepas, mengaktifkan kembali...');
          await WakelockPlus.enable();
          final refreshed = await WakelockPlus.enabled;
          debugPrint('[KEEP_SCREEN_ON] Status wakelock: $refreshed');
        }
      } catch (_) {}
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  /// Mengubah status Keep Screen On berdasarkan nilai [enabled].
  Future<bool> toggle({required bool enabled, String? source}) async {
    return enabled ? await enable(source: source) : await disable(source: source);
  }

  /// Memeriksa status nyata apakah wakelock sedang aktif pada platform perangkat saat ini.
  Future<bool> isEnabled() async {
    try {
      return await WakelockPlus.enabled;
    } catch (e) {
      debugPrint('[KEEP_SCREEN_ON] Gagal membaca status wakelock: $e');
      return _isRequested;
    }
  }
}

/// Widget pembungkus (scope) opsional untuk mengaktifkan Keep Screen On secara otomatis
/// pada halaman berbasis StatelessWidget / ConsumerWidget tanpa perlu mengubah struktur state.
class KeepScreenOnPageScope extends StatefulWidget {
  const KeepScreenOnPageScope({
    super.key,
    required this.child,
    this.pageName = 'PageScope',
  });

  final Widget child;
  final String pageName;

  @override
  State<KeepScreenOnPageScope> createState() => _KeepScreenOnPageScopeState();
}

class _KeepScreenOnPageScopeState extends State<KeepScreenOnPageScope>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    debugPrint('[KEEP_SCREEN_ON] Halaman dibuka (${widget.pageName})');
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        KeepScreenOnService.instance.enable(source: '${widget.pageName}.initState');
      }
    });
  }

  @override
  void dispose() {
    debugPrint('[KEEP_SCREEN_ON] Halaman ditutup (${widget.pageName})');
    WidgetsBinding.instance.removeObserver(this);
    KeepScreenOnService.instance.disable(source: '${widget.pageName}.dispose');
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint('[KEEP_SCREEN_ON] Lifecycle berubah (${widget.pageName}): $state');
    if (state == AppLifecycleState.resumed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final isCurrent = ModalRoute.of(context)?.isCurrent ?? true;
          if (isCurrent) {
            KeepScreenOnService.instance.enable(source: '${widget.pageName}.resumed');
          }
        }
      });
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      KeepScreenOnService.instance.disable(source: '${widget.pageName}.$state');
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
