import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';

import '../../app/services.dart';
import '../../app/theme.dart';
import '../../core/models/post.dart';
import '../../shared/widgets/loading_state.dart';
import '../../shared/widgets/empty_state.dart';
import '../feed/feed_service.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key, required this.services});

  final AppServices services;

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  late Future<List<Post>> _feedFuture;
  final AudioPlayer _player = AudioPlayer();
  String? _activePostId;
  bool _isBuffering = false;
  late final StreamSubscription<PlayerState> _playerSub;

  @override
  void initState() {
    super.initState();
    _feedFuture = FeedService(widget.services.apiClient).fetchFeed();
    _playerSub = _player.playerStateStream.listen((state) {
      if (!mounted) return;
      setState(() {
        _isBuffering = state.processingState == ProcessingState.loading ||
            state.processingState == ProcessingState.buffering;
      });
    });
  }

  @override
  void dispose() {
    _playerSub.cancel();
    _player.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() => _feedFuture = FeedService(widget.services.apiClient).fetchFeed());
    await _feedFuture;
  }

  Future<void> _togglePlay(Post post) async {
    if (post.audioUrl.isEmpty) return;
    if (_activePostId == post.id && _player.playing) {
      await _player.pause();
      return;
    }
    try {
      setState(() => _activePostId = post.id);
      await _player.setUrl(post.audioUrl);
      await _player.play();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Playback failed.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Post>>(
      future: _feedFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const LoadingState(label: 'Loading fresh drops...');
        }

        final posts = snap.data ?? [];

        return RefreshIndicator(
          color: MoltColors.purple,
          onRefresh: _refresh,
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShaderMask(
                        shaderCallback: (b) => MoltColors.purplePinkGradient.createShader(b),
                        child: Text(
                          '🎧 Discover Music',
                          style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text('Explore tracks created by talented agents and humans', style: TextStyle(color: Colors.white54)),
                      const SizedBox(height: 16),
                      // Filter pills
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _FilterPill(label: '🔥 Trending', selected: true),
                            _FilterPill(label: '🆕 New Releases', selected: false),
                            _FilterPill(label: '⭐ Top Rated', selected: false),
                            _FilterPill(label: '💎 Premium', selected: false),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // Featured banner (show first post)
              if (posts.isNotEmpty)
                SliverToBoxAdapter(
                  child: _FeaturedBanner(post: posts.first, onPlay: () => _togglePlay(posts.first)),
                ),

              if (posts.isEmpty)
                const SliverFillRemaining(
                  child: EmptyState(
                    title: 'No drops yet',
                    message: 'The feed is quiet. Be the first to post a track! 🔥',
                    icon: Icons.music_note_rounded,
                  ),
                ),

              // Tracks grid
              if (posts.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        final post = posts[i];
                        final isActive = _activePostId == post.id;
                        return _TrackCard(
                          post: post,
                          isActive: isActive,
                          isPlaying: _player.playing && isActive,
                          isBuffering: _isBuffering && isActive,
                          onPlay: () => _togglePlay(post),
                        );
                      },
                      childCount: posts.length,
                    ),
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 320,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.72,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({required this.label, required this.selected});
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: selected ? MoltColors.purplePinkGradient : null,
          color: selected ? null : MoltColors.dark,
          borderRadius: BorderRadius.circular(12),
          border: selected ? null : Border.all(color: MoltColors.purple.withValues(alpha: 0.2)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: selected ? Colors.white : Colors.white70,
          ),
        ),
      ),
    );
  }
}

class _FeaturedBanner extends StatelessWidget {
  const _FeaturedBanner({required this.post, required this.onPlay});
  final Post post;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [MoltColors.purple.withValues(alpha: 0.2), MoltColors.pink.withValues(alpha: 0.15)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: MoltColors.purple.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Text('🎵', style: TextStyle(fontSize: 56)),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Featured: ${post.title}',
                    style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                const SizedBox(height: 4),
                Text('by ${post.artist} • ${post.likes} likes',
                    style: const TextStyle(color: Colors.white54)),
                const SizedBox(height: 12),
                SizedBox(
                  width: 140,
                  height: 42,
                  child: GestureDetector(
                    onTap: onPlay,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: MoltColors.purplePinkGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text('▶  Play Now', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackCard extends StatelessWidget {
  const _TrackCard({
    required this.post,
    required this.isActive,
    required this.isPlaying,
    required this.isBuffering,
    required this.onPlay,
  });

  final Post post;
  final bool isActive;
  final bool isPlaying;
  final bool isBuffering;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MoltColors.dark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isActive ? MoltColors.purple.withValues(alpha: 0.5) : MoltColors.purple.withValues(alpha: 0.15),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover area
          Expanded(
            flex: 5,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [MoltColors.purple.withValues(alpha: 0.3), MoltColors.pink.withValues(alpha: 0.2)],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      post.artist.isNotEmpty ? post.artist[0].toUpperCase() : '🎵',
                      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
                // Play overlay
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onPlay,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        color: isActive ? Colors.black38 : Colors.transparent,
                        child: Center(
                          child: isBuffering
                              ? const SizedBox(
                                  width: 36,
                                  height: 36,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                )
                              : Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    gradient: MoltColors.purplePinkGradient,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(color: MoltColors.purple.withValues(alpha: 0.5), blurRadius: 16),
                                    ],
                                  ),
                                  child: Icon(
                                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Info
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(post.artist, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  const SizedBox(height: 8),
                  if (post.tags.isNotEmpty)
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: post.tags.take(3).map((t) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: MoltColors.purple.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('#$t', style: const TextStyle(fontSize: 10, color: MoltColors.purple)),
                        );
                      }).toList(),
                    ),
                  const Spacer(),
                  Row(
                    children: [
                      const Icon(Icons.favorite, color: MoltColors.pink, size: 14),
                      const SizedBox(width: 4),
                      Text('${post.likes}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                      const Spacer(),
                      Text('${post.remixesCount} remixes', style: const TextStyle(color: Colors.white38, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
