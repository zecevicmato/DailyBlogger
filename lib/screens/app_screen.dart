import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../config/theme.dart';
import '../models/post.dart';
import '../models/profile.dart';
import '../services/supabase_service.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_background.dart';
import '../widgets/post_card.dart';

class AppScreen extends StatefulWidget {
  const AppScreen({super.key});

  @override
  State<AppScreen> createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> {
  late Future<List<Post>> _posts;
  late Future<Profile?> _profile;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    _posts = SupabaseService.instance.fetchPosts();
    _profile = SupabaseService.instance.getCurrentProfile();
  }

  Future<void> _reload() async {
    setState(_refresh);
    await Future.wait([_posts, _profile]);
  }

  Future<void> _logout() async {
    await SupabaseService.instance.signOut();
    if (!mounted) return;
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ringColor = dark ? AppColors.darkGlowCyan : AppColors.lightGlowViolet;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        titleSpacing: 16,
        title: FutureBuilder<Profile?>(
          future: _profile,
          builder: (context, snap) {
            final profile = snap.data;
            final photoUrl = profile?.photoUrl;
            return Row(
              children: [
                Hero(
                  tag: 'avatar-${profile?.id ?? "me"}',
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(
                        colors: [
                          ringColor,
                          ringColor.withValues(alpha: 0.35),
                          ringColor,
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(2),
                    child: CircleAvatar(
                      radius: 21,
                      backgroundColor:
                          Theme.of(context).scaffoldBackgroundColor,
                      child: ClipOval(
                        child: SizedBox(
                          width: 38,
                          height: 38,
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
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Hey,',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.color
                              ?.withValues(alpha: 0.65),
                        ),
                      ),
                      Text(
                        profile?.username ?? '...',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded),
          ),
          const SizedBox(width: 4),
        ],
      ),
      floatingActionButton: _GlowFab(
        onPressed: () async {
          final created = await context.push<bool>('/add-post');
          if (created == true) _reload();
        },
      ),
      body: GradientBackground(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _reload,
            child: FutureBuilder<List<Post>>(
              future: _posts,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text('Failed to load posts: ${snap.error}'),
                    ),
                  );
                }
                final posts = snap.data ?? const [];
                if (posts.isEmpty) {
                  return ListView(
                    children: [
                      const SizedBox(height: 100),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: GlassCard(
                          padding: const EdgeInsets.all(28),
                          child: Column(
                            children: [
                              Icon(Icons.auto_awesome_rounded,
                                  size: 48,
                                  color:
                                      Theme.of(context).colorScheme.primary),
                              const SizedBox(height: 12),
                              const Text(
                                'Nothing here yet',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Tap + to share your first moment.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.color
                                      ?.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  itemCount: posts.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 14),
                  itemBuilder: (_, i) => PostCard(post: posts[i])
                      .animate()
                      .fadeIn(
                        delay: Duration(milliseconds: 60 * i),
                        duration: AppDurations.normal,
                      )
                      .slideY(
                        begin: 0.08,
                        end: 0,
                        curve: Curves.easeOutCubic,
                      ),
                );
              },
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
}

class _GlowFab extends StatelessWidget {
  final VoidCallback onPressed;
  const _GlowFab({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final accent = dark ? AppColors.darkGlowCyan : AppColors.lightGlowViolet;
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.55),
            blurRadius: 28,
            spreadRadius: -2,
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: accent,
        foregroundColor: Colors.white,
        elevation: 0,
        child: const Icon(Icons.add_rounded, size: 30),
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scaleXY(
          begin: 1.0,
          end: 1.05,
          duration: const Duration(milliseconds: 1400),
          curve: Curves.easeInOut,
        );
  }
}
