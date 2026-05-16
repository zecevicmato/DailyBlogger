import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppColors {
  // Dark palette — navy + neon accent
  static const Color darkBg = Color(0xFF070B1F);
  static const Color darkBgMid = Color(0xFF101535);
  static const Color darkBgEdge = Color(0xFF1C2155);
  static const Color darkGlowCyan = Color(0xFF22D3EE);
  static const Color darkGlowViolet = Color(0xFFA78BFA);
  static const Color darkGlowPink = Color(0xFFF472B6);

  // Light palette — soft cream + same accent family
  static const Color lightBg = Color(0xFFF1F4FF);
  static const Color lightBgMid = Color(0xFFE3E9FF);
  static const Color lightBgEdge = Color(0xFFCBD6FF);
  static const Color lightGlowCyan = Color(0xFF0EA5E9);
  static const Color lightGlowViolet = Color(0xFF7C3AED);

  // Glass surface helpers
  static Color glassFillDark(double opacity) =>
      Colors.white.withValues(alpha: opacity);
  static Color glassFillLight(double opacity) =>
      Colors.white.withValues(alpha: opacity);
  static Color glassBorderDark = Colors.white.withValues(alpha: 0.12);
  static Color glassBorderLight = Colors.white.withValues(alpha: 0.55);
}

class AppRadii {
  static const double card = 24;
  static const double button = 18;
  static const double field = 16;
}

class AppDurations {
  static const fast = Duration(milliseconds: 220);
  static const normal = Duration(milliseconds: 360);
  static const slow = Duration(milliseconds: 600);
}

const _systemDark = SystemUiOverlayStyle(
  statusBarColor: Colors.transparent,
  statusBarIconBrightness: Brightness.light,
  statusBarBrightness: Brightness.dark,
  systemNavigationBarColor: AppColors.darkBg,
);

const _systemLight = SystemUiOverlayStyle(
  statusBarColor: Colors.transparent,
  statusBarIconBrightness: Brightness.dark,
  statusBarBrightness: Brightness.light,
  systemNavigationBarColor: AppColors.lightBg,
);

ThemeData buildDarkTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.darkGlowCyan,
    brightness: Brightness.dark,
    primary: AppColors.darkGlowCyan,
    secondary: AppColors.darkGlowViolet,
    surface: AppColors.darkBgMid,
  );
  return base.copyWith(
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.darkBg,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      elevation: 0,
      systemOverlayStyle: _systemDark,
    ),
    textTheme: base.textTheme.apply(
      bodyColor: Colors.white.withValues(alpha: 0.92),
      displayColor: Colors.white,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.iOS: _FadeThroughTransitionsBuilder(),
        TargetPlatform.android: _FadeThroughTransitionsBuilder(),
        TargetPlatform.macOS: _FadeThroughTransitionsBuilder(),
      },
    ),
  );
}

ThemeData buildLightTheme() {
  final base = ThemeData.light(useMaterial3: true);
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.lightGlowViolet,
    brightness: Brightness.light,
    primary: AppColors.lightGlowViolet,
    secondary: AppColors.lightGlowCyan,
    surface: AppColors.lightBgMid,
  );
  return base.copyWith(
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.lightBg,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Color(0xFF1F2552),
      elevation: 0,
      systemOverlayStyle: _systemLight,
    ),
    textTheme: base.textTheme.apply(
      bodyColor: const Color(0xFF1F2552),
      displayColor: const Color(0xFF0F1339),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.iOS: _FadeThroughTransitionsBuilder(),
        TargetPlatform.android: _FadeThroughTransitionsBuilder(),
        TargetPlatform.macOS: _FadeThroughTransitionsBuilder(),
      },
    ),
  );
}

class _FadeThroughTransitionsBuilder extends PageTransitionsBuilder {
  const _FadeThroughTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.04),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}
