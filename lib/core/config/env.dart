/// Konfigurasi Supabase. Nilainya diisi lewat `--dart-define` saat run/build,
/// jadi tidak ada key yang tersimpan di source code:
///
///   flutter run \
///     --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
///     --dart-define=SUPABASE_ANON_KEY=eyJhbGciOi...
///
/// Pakai ANON key (bukan service_role). Akses data dibatasi oleh RLS di database.
class Env {
  Env._();

  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
