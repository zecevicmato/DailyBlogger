import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../config/theme.dart';
import '../services/supabase_service.dart';
import '../widgets/glass_button.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_text_field.dart';
import '../widgets/gradient_background.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtl = TextEditingController();
  final _emailCtl = TextEditingController();
  final _passwordCtl = TextEditingController();
  File? _photo;
  bool _loading = false;

  @override
  void dispose() {
    _nameCtl.dispose();
    _emailCtl.dispose();
    _passwordCtl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() => _photo = File(picked.path));
    }
  }

  Future<void> _register() async {
    final username = _nameCtl.text.trim();
    final email = _emailCtl.text.trim();
    final password = _passwordCtl.text;
    final messenger = ScaffoldMessenger.of(context);

    if (email.isEmpty || password.isEmpty || username.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Please enter name, email and password.')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await SupabaseService.instance.signUp(
        email: email,
        password: password,
        username: username,
        photo: _photo,
      );
      if (!mounted) return;
      context.go('/app');
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Register failed: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ringColor = dark ? AppColors.darkGlowCyan : AppColors.lightGlowViolet;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
      ),
      body: GradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                Center(
                  child: GestureDetector(
                    onTap: _pickPhoto,
                    child: AnimatedContainer(
                      duration: AppDurations.fast,
                      width: 124,
                      height: 124,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: SweepGradient(
                          colors: [
                            ringColor,
                            ringColor.withValues(alpha: 0.4),
                            ringColor,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: ringColor.withValues(alpha: 0.45),
                            blurRadius: 30,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(3),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).scaffoldBackgroundColor,
                        ),
                        padding: const EdgeInsets.all(3),
                        child: ClipOval(
                          child: _photo != null
                              ? Image.file(_photo!, fit: BoxFit.cover)
                              : Image.asset(
                                  'assets/images/user_placeholder.png',
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(duration: AppDurations.normal)
                    .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
                const SizedBox(height: 12),
                Text(
                  'Create your account',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  _photo == null
                      ? 'Tap the circle to add a profile photo'
                      : 'Looking sharp',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.color
                            ?.withValues(alpha: 0.7),
                      ),
                ),
                const SizedBox(height: 24),
                GlassCard(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 22),
                  child: Column(
                    children: [
                      GlassTextField(
                        controller: _nameCtl,
                        hint: 'Full Name',
                        icon: Icons.person_outline_rounded,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 12),
                      GlassTextField(
                        controller: _emailCtl,
                        hint: 'Email',
                        icon: Icons.alternate_email_rounded,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 12),
                      GlassTextField(
                        controller: _passwordCtl,
                        hint: 'Password',
                        icon: Icons.lock_outline_rounded,
                        obscure: true,
                        textInputAction: TextInputAction.done,
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(delay: 120.ms, duration: AppDurations.normal)
                    .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
                const SizedBox(height: 24),
                Center(
                  child: GlassButton(
                    label: 'CREATE ACCOUNT',
                    icon: Icons.auto_awesome_rounded,
                    loading: _loading,
                    width: 260,
                    onPressed: _loading ? null : _register,
                  )
                      .animate()
                      .fadeIn(delay: 240.ms, duration: AppDurations.normal),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
