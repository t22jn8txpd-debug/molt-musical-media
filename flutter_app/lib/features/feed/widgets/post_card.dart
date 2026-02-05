import 'package:flutter/material.dart';

import '../../../core/models/post.dart';

class PostCard extends StatelessWidget {
  const PostCard({super.key, required this.post, required this.child});

  final Post post;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF171B25), Color(0xFF1B2A3A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFF2C3647),
                backgroundImage: post.artworkUrl != null ? NetworkImage(post.artworkUrl!) : null,
                child: post.artworkUrl == null
                    ? Text(
                        post.artist.isNotEmpty ? post.artist[0].toUpperCase() : 'M',
                        style: Theme.of(context).textTheme.titleMedium,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      post.artist,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              Chip(
                label: Text('${post.likes} likes'),
              ),
            ],
          ),
          if (post.caption != null) ...[
            const SizedBox(height: 12),
            Text(
              post.caption!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
            ),
          ],
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
