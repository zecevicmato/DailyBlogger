import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../config/theme.dart';
import '../models/profile.dart';
import '../services/supabase_service.dart';
import '../widgets/glass_button.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_text_field.dart';
import '../widgets/gradient_background.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final _descriptionCtl = TextEditingController();
  File? _photo;
  Profile? _profile;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    SupabaseService.instance.getCurrentProfile().then((p) {
      if (mounted) setState(() => _profile = p);
    });
  }

  @override
  void dispose() {
    _descriptionCtl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() => _photo = File(picked.path));
    }
  }

  Future<void> _upload() async {
    final desc = _descriptionCtl.text.trim();
    final messenger = ScaffoldMessenger.of(context);
    if (_photo == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Please pick a photo first.')),
      );
      return;
    }
    setState(() => _uploading = true);
    try {
      await SupabaseService.instance.createPost(
        description: desc,
        imageFile: _photo!,
      );
      if (!mounted) return;
      context.pop(true);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ringColor = dark ? AppColors.darkGlowCyan : AppColors.lightGlowViolet;
    final photoUrl = _profile?.photoUrl;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'New post',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: GradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: SweepGradient(colors: [
                            ringColor,
                            ringColor.withValues(alpha: 0.3),
                            ringColor,
                          ]),
                        ),
                        padding: const EdgeInsets.all(2),
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor:
                              Theme.of(context).scaffoldBackgroundColor,
                          child: ClipOval(
                            child: SizedBox(
                              width: 44,
                              height: 44,
                              child: (photoUrl != null && photoUrl.isNotEmpty)
                                  ? CachedNetworkImage(
                                      imageUrl: photoUrl,
                                      fit: BoxFit.cover,
                                      placeholder: (_, _) => _placeholder(),
                                      errorWidget: (_, _, _) => _placeholder(),
                                    )
                                  : _placeholder(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _profile?.username ?? '...',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Posting publicly',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.color
                                    ?.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(duration: AppDurations.normal)
                    .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _pickPhoto,
                  child: AspectRatio(
                    aspectRatio: 4 / 3,
                    child: GlassCard(
                      padding: EdgeInsets.zero,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadii.card - 2),
                        child: _photo == null
                            ? _photoPlaceholder(context)
                            : Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.file(_photo!, fit: BoxFit.cover),
                                  Positioned(
                                    top: 12,
                                    right: 12,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.swap_horiz_rounded,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(
                        delay: 100.ms, duration: AppDurations.normal)
                    .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
                const SizedBox(height: 16),
                GlassTextField(
                  controller: _descriptionCtl,
                  hint: 'Say something about this moment...',
                  icon: Icons.edit_outlined,
                  maxLines: 4,
                )
                    .animate()
                    .fadeIn(
                        delay: 180.ms, duration: AppDurations.normal)
                    .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
                const SizedBox(height: 24),
                Center(
                  child: GlassButton(
                    label: 'POST',
                    icon: Icons.send_rounded,
                    loading: _uploading,
                    width: 220,
                    onPressed: _uploading ? null : _upload,
                  )
                      .animate()
                      .fadeIn(delay: 280.ms, duration: AppDurations.normal),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _placeholder() => Image.asset(
        'assets/images/user_placeholder.png',
        fit: BoxFit.cover,
      );

  Widget _photoPlaceholder(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: Colors.white.withValues(alpha: dark ? 0.04 : 0.35),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              'Tap to choose a photo',
              style: TextStyle(
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color
                    ?.withValues(alpha: 0.75),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
