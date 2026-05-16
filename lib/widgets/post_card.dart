import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../config/theme.dart';
import '../models/post.dart';
import 'glass_card.dart';

class PostCard extends StatelessWidget {
  final Post post;
  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final hasUserPhoto = (post.userPhotoUrl ?? '').isNotEmpty;
    final ringColor = dark ? AppColors.darkGlowCyan : AppColors.lightGlowViolet;
    final dateLabel = _formatRelative(post.createdAt);

    return GlassCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: [
                      ringColor,
                      ringColor.withValues(alpha: 0.3),
                      ringColor,
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(2),
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor:
                      Theme.of(context).scaffoldBackgroundColor,
                  child: ClipOval(
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: hasUserPhoto
                          ? CachedNetworkImage(
                              imageUrl: post.userPhotoUrl!,
                              fit: BoxFit.cover,
                              placeholder: (_, _) => _placeholder(),
                              errorWidget: (_, _, _) => _placeholder(),
                            )
                          : _placeholder(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.username ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      dateLabel,
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
          if (post.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              post.description,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
          ],
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: post.imageUrl.isEmpty
                  ? Container(color: Colors.black12)
                  : CachedNetworkImage(
                      imageUrl: post.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => Container(
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                      errorWidget: (_, _, _) =>
                          const Icon(Icons.broken_image, size: 60),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() => Image.asset(
        'assets/images/user_placeholder.png',
        fit: BoxFit.cover,
      );

  String _formatRelative(DateTime ts) {
    final diff = DateTime.now().difference(ts);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${ts.day}.${ts.month}.${ts.year}';
  }
}
