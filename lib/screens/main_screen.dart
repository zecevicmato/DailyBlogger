import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../config/theme.dart';
import '../widgets/glass_button.dart';
import '../widgets/gradient_background.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final accentGlow = dark
        ? AppColors.darkGlowCyan.withValues(alpha: 0.45)
        : AppColors.lightGlowViolet.withValues(alpha: 0.30);

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16),
                  Hero(
                    tag: 'app-logo',
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: accentGlow,
                            blurRadius: 60,
                            spreadRadius: 6,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: AppDurations.slow)
                      .scale(
                        begin: const Offset(0.92, 0.92),
                        end: const Offset(1, 1),
                        duration: AppDurations.slow,
                        curve: Curves.easeOutCubic,
                      ),
                  const SizedBox(height: 36),
                  Text(
                    'DailyBlogger',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                  )
                      .animate()
                      .fadeIn(delay: 150.ms, duration: AppDurations.normal)
                      .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),
                  const SizedBox(height: 8),
                  Text(
                    'Share your day in a single frame.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withValues(alpha: 0.7),
                        ),
                  )
                      .animate()
                      .fadeIn(delay: 250.ms, duration: AppDurations.normal),
                  const SizedBox(height: 48),
                  GlassButton(
                    label: 'LOGIN',
                    icon: Icons.login_rounded,
                    onPressed: () => context.push('/login'),
                  )
                      .animate()
                      .fadeIn(delay: 400.ms, duration: AppDurations.normal)
                      .slideY(begin: 0.3, end: 0, curve: Curves.easeOutCubic),
                  const SizedBox(height: 14),
                  GlassButton(
                    label: 'REGISTER',
                    icon: Icons.person_add_alt_1_rounded,
                    style: GlassButtonStyle.secondary,
                    onPressed: () => context.push('/register'),
                  )
                      .animate()
                      .fadeIn(delay: 500.ms, duration: AppDurations.normal)
                      .slideY(begin: 0.3, end: 0, curve: Curves.easeOutCubic),
                  const SizedBox(height: 14),
                  GlassButton(
                    label: 'CONTINUE AS GUEST',
                    icon: Icons.visibility_outlined,
                    style: GlassButtonStyle.secondary,
                    onPressed: () => context.push('/guest'),
                  )
                      .animate()
                      .fadeIn(delay: 600.ms, duration: AppDurations.normal)
                      .slideY(begin: 0.3, end: 0, curve: Curves.easeOutCubic),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
