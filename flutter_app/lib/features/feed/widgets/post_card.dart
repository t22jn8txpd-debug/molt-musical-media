import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../core/models/post.dart';

class PostCard extends StatelessWidget {
  const PostCard({super.key, required this.post, required this.child});

  final Post post;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: MoltColors.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: MoltColors.purple.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: MoltColors.purple.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: MoltColors.purplePinkGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: post.artworkUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.network(
                              post.artworkUrl!,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _avatarFallback(post),
                            ),
                          )
                        : _avatarFallback(post),
                  ),
                ),
                const SizedBox(width: 14),
                // Title & Artist
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        post.artist,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: MoltColors.textMuted,
                            ),
                      ),
                    ],
                  ),
                ),
                // Likes
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: MoltColors.pink.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: MoltColors.pink.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.favorite, color: MoltColors.pink, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${post.likes}',
                        style: const TextStyle(
                          color: MoltColors.pink,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Description
          if (post.caption != null && post.caption!.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
              child: Text(
                post.caption!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                      height: 1.4,
                    ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          // Player
          Padding(
            padding: const EdgeInsets.all(14),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _avatarFallback(Post post) {
    return Text(
      post.artist.isNotEmpty ? post.artist[0].toUpperCase() : '🎵',
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w800,
        fontSize: 20,
      ),
    );
  }
}
