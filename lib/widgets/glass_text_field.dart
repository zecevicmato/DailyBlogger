import 'dart:ui';

import 'package:flutter/material.dart';

import '../config/theme.dart';

class GlassTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData? icon;
  final bool obscure;
  final TextInputType? keyboardType;
  final int maxLines;
  final TextInputAction? textInputAction;

  const GlassTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.icon,
    this.obscure = false,
    this.keyboardType,
    this.maxLines = 1,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final border = dark
        ? Colors.white.withValues(alpha: 0.14)
        : Colors.white.withValues(alpha: 0.7);
    final fill = dark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.white.withValues(alpha: 0.55);
    final fg = dark ? Colors.white : const Color(0xFF1F2552);
    final hintColor = dark
        ? Colors.white.withValues(alpha: 0.45)
        : const Color(0xFF1F2552).withValues(alpha: 0.55);
    final iconColor = dark
        ? AppColors.darkGlowCyan
        : AppColors.lightGlowViolet;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.field),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(AppRadii.field),
            border: Border.all(color: border, width: 1),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            keyboardType: keyboardType,
            maxLines: obscure ? 1 : maxLines,
            textInputAction: textInputAction,
            style: TextStyle(color: fg, fontSize: 15),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: hintColor, fontSize: 15),
              prefixIcon: icon == null
                  ? null
                  : Icon(icon, color: iconColor, size: 20),
              contentPadding: EdgeInsets.symmetric(
                horizontal: icon == null ? 18 : 8,
                vertical: maxLines > 1 ? 18 : 16,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }
}
