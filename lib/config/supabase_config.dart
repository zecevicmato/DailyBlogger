class SupabaseConfig {
  static const String url = String.fromEnvironment('SUPABASE_URL');
  static const String anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static const String userPhotosBucket = 'user-photos';
  static const String postImagesBucket = 'post-images';

  static void ensureConfigured() {
    if (url.isEmpty || anonKey.isEmpty) {
      throw StateError(
        'Supabase credentials missing. Run the app via:\n'
        '  ./run.sh                       (reads .env)\n'
        'or manually:\n'
        '  flutter run \\\n'
        '    --dart-define=SUPABASE_URL=https://YOUR-PROJECT.supabase.co \\\n'
        '    --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY',
      );
    }
  }
}
