import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/supabase_config.dart';
import 'config/theme.dart';
import 'screens/add_post_screen.dart';
import 'screens/app_screen.dart';
import 'screens/guest_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'screens/register_screen.dart';
import 'services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SupabaseConfig.ensureConfigured();
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );
  runApp(const DailyBloggerApp());
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const MainScreen()),
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
    GoRoute(path: '/guest', builder: (_, __) => const GuestScreen()),
    GoRoute(path: '/app', builder: (_, __) => const AppScreen()),
    GoRoute(path: '/add-post', builder: (_, __) => const AddPostScreen()),
  ],
  redirect: (context, state) {
    final loggedIn = SupabaseService.instance.isSignedIn;
    final loc = state.matchedLocation;
    final protected = loc == '/app' || loc == '/add-post';
    if (protected && !loggedIn) return '/login';
    return null;
  },
);

class DailyBloggerApp extends StatelessWidget {
  const DailyBloggerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'DailyBlogger',
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: ThemeMode.system,
      routerConfig: _router,
    );
  }
}
