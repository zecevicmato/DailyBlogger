import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../config/theme.dart';

/// Animated mesh-style gradient with two slowly drifting color blobs.
/// Adapts to light/dark theme automatically.
class GradientBackground extends StatelessWidget {
  final Widget child;
  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bg = dark ? AppColors.darkBg : AppColors.lightBg;
    final blobA = dark ? AppColors.darkGlowViolet : AppColors.lightGlowViolet;
    final blobB = dark ? AppColors.darkGlowCyan : AppColors.lightGlowCyan;
    return Container(
      color: bg,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _Blob(color: blobA, alignmentStart: const Alignment(-1.1, -1.0))
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .moveX(
                begin: 0,
                end: 40,
                duration: const Duration(seconds: 8),
                curve: Curves.easeInOut,
              )
              .moveY(
                begin: 0,
                end: 30,
                duration: const Duration(seconds: 10),
                curve: Curves.easeInOut,
              ),
          _Blob(color: blobB, alignmentStart: const Alignment(1.2, 1.0))
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .moveX(
                begin: 0,
                end: -50,
                duration: const Duration(seconds: 11),
                curve: Curves.easeInOut,
              )
              .moveY(
                begin: 0,
                end: -40,
                duration: const Duration(seconds: 9),
                curve: Curves.easeInOut,
              ),
          // Subtle vignette so glass elements pop in both modes
          IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  radius: 1.0,
                  colors: [
                    Colors.transparent,
                    (dark ? Colors.black : Colors.black).withValues(
                      alpha: dark ? 0.25 : 0.05,
                    ),
                  ],
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  final Color color;
  final Alignment alignmentStart;
  const _Blob({required this.color, required this.alignmentStart});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Align(
      alignment: alignmentStart,
      child: Container(
        width: 380,
        height: 380,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: dark ? 0.55 : 0.45),
              color.withValues(alpha: 0.0),
            ],
          ),
        ),
      ),
    );
  }
}
