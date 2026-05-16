import 'dart:ui';

import 'package:flutter/material.dart';

import '../config/theme.dart';

enum GlassButtonStyle { primary, secondary }

class GlassButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final GlassButtonStyle style;
  final IconData? icon;
  final bool loading;
  final double width;
  final double height;

  const GlassButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.style = GlassButtonStyle.primary,
    this.icon,
    this.loading = false,
    this.width = 220,
    this.height = 56,
  });

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final primary = widget.style == GlassButtonStyle.primary;
    final accent = primary
        ? (dark ? AppColors.darkGlowCyan : AppColors.lightGlowViolet)
        : (dark ? AppColors.darkGlowViolet : AppColors.lightGlowCyan);

    final disabled = widget.onPressed == null || widget.loading;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: disabled ? null : widget.onPressed,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: AppDurations.fast,
        curve: Curves.easeOut,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.button),
            boxShadow: [
              if (primary && !disabled)
                BoxShadow(
                  color: accent.withValues(alpha: dark ? 0.55 : 0.35),
                  blurRadius: 28,
                  spreadRadius: -4,
                  offset: const Offset(0, 8),
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.button),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: primary
                        ? [
                            accent.withValues(alpha: dark ? 0.85 : 0.95),
                            accent.withValues(alpha: dark ? 0.55 : 0.75),
                          ]
                        : [
                            Colors.white.withValues(alpha: dark ? 0.10 : 0.55),
                            Colors.white.withValues(alpha: dark ? 0.04 : 0.30),
                          ],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: dark ? 0.18 : 0.6),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(AppRadii.button),
                ),
                alignment: Alignment.center,
                child: widget.loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(widget.icon, size: 18, color: _fg(dark, primary)),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            widget.label,
                            style: TextStyle(
                              color: _fg(dark, primary),
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _fg(bool dark, bool primary) {
    if (primary) return Colors.white;
    return dark ? Colors.white : const Color(0xFF1F2552);
  }
}
