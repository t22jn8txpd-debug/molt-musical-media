import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';

import '../../app/services.dart';
import '../../app/theme.dart';
import '../../core/models/post.dart';
import '../../shared/widgets/gradient_button.dart';
import '../../shared/widgets/loading_state.dart';
import '../../shared/widgets/empty_state.dart';
import '../feed/feed_service.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key, required this.services});

  final AppServices services;

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<Post>> _feedFuture;
  final AudioPlayer _player = AudioPlayer();
  String? _activePostId;
  bool _isBuffering = false;
  late final StreamSubscription<PlayerState> _playerSub;

  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedGenre;

  static const _genreFilters = [
    'All', 'Romantic', 'Rock', 'Hip-Hop', 'EDM', 'Christian',
    'R&B', 'Pop', 'Country', 'Jazz', 'Lo-Fi', 'Trap', 'Afrobeats',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
    _tabController.dispose();
    _playerSub.cancel();
    _player.dispose();
    _searchController.dispose();
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
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Playback failed.')));
      }
    }
  }

  List<Post> _filterPosts(List<Post> posts) {
    var filtered = posts;

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered.where((p) {
        return p.title.toLowerCase().contains(q) ||
            p.artist.toLowerCase().contains(q) ||
            p.tags.any((t) => t.toLowerCase().contains(q));
      }).toList();
    }

    // Genre filter
    if (_selectedGenre != null && _selectedGenre != 'All') {
      final g = _selectedGenre!.toLowerCase();
      filtered = filtered.where((p) {
        return p.tags.any((t) => t.toLowerCase().contains(g)) ||
            p.title.toLowerCase().contains(g);
      }).toList();
    }

    return filtered;
  }

  // Simple recommendation: mix trending (by likes) with recent
  List<Post> _recommendPosts(List<Post> posts) {
    if (posts.length <= 3) return posts;
    final sorted = List<Post>.from(posts);
    // Sort by likes (trending)
    sorted.sort((a, b) => b.likes.compareTo(a.likes));
    final trending = sorted.take((posts.length * 0.4).ceil()).toList();
    // Recent
    final recent = posts.take((posts.length * 0.6).ceil()).toList();
    // Merge: alternate trending and recent
    final result = <Post>[];
    final seen = <String>{};
    int t = 0, r = 0;
    while (result.length < posts.length) {
      if (t < trending.length && !seen.contains(trending[t].id)) {
        seen.add(trending[t].id);
        result.add(trending[t]);
        t++;
      }
      if (r < recent.length && !seen.contains(recent[r].id)) {
        seen.add(recent[r].id);
        result.add(recent[r]);
        r++;
      }
      if (t >= trending.length && r >= recent.length) break;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: MoltColors.backgroundGradient),
      child: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: '🔍 Search tracks, albums, artists...',
                hintStyle: const TextStyle(color: MoltColors.textMuted, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: MoltColors.purple),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: MoltColors.textMuted),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Genre filter chips
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _genreFilters.length,
              itemBuilder: (context, index) {
                final genre = _genreFilters[index];
                final isSelected = (_selectedGenre ?? 'All') == genre;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedGenre = genre == 'All' ? null : genre),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: isSelected ? MoltColors.purplePinkGradient : null,
                        color: isSelected ? null : MoltColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: isSelected ? null : Border.all(color: MoltColors.purple.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        genre,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Tabs: For You / Music Videos
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: MoltColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: MoltColors.purple.withValues(alpha: 0.2)),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  gradient: MoltColors.purplePinkGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerHeight: 0,
                labelColor: Colors.white,
                unselectedLabelColor: MoltColors.textMuted,
                labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                tabs: const [
                  Tab(text: '🔥 For You'),
                  Tab(text: '🎬 Music Videos'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Content
          Expanded(
            child: FutureBuilder<List<Post>>(
              future: _feedFuture,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const LoadingState(label: 'Loading fresh drops...');
                }

                final allPosts = snap.data ?? [];
                final filtered = _filterPosts(allPosts);
                final recommended = _recommendPosts(filtered);

                // Split into tracks and videos
                final trackPosts = recommended.where((p) =>
                    !p.tags.any((t) => t.contains('music-video') || t.contains('video'))).toList();
                final videoPosts = recommended.where((p) =>
                    p.tags.any((t) => t.contains('music-video') || t.contains('video'))).toList();

                return TabBarView(
                  controller: _tabController,
                  children: [
                    // For You Feed
                    _ForYouFeed(
                      posts: trackPosts.isEmpty ? recommended : trackPosts,
                      activePostId: _activePostId,
                      isPlaying: _player.playing,
                      isBuffering: _isBuffering,
                      onPlay: _togglePlay,
                      onRefresh: _refresh,
                      services: widget.services,
                    ),
                    // Music Videos Feed
                    _ForYouFeed(
                      posts: videoPosts,
                      activePostId: _activePostId,
                      isPlaying: _player.playing,
                      isBuffering: _isBuffering,
                      onPlay: _togglePlay,
                      onRefresh: _refresh,
                      services: widget.services,
                      isVideoFeed: true,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════
// FOR YOU FEED (TikTok-style vertical scroll)
// ═══════════════════════════════════════

class _ForYouFeed extends StatelessWidget {
  const _ForYouFeed({
    required this.posts,
    required this.activePostId,
    required this.isPlaying,
    required this.isBuffering,
    required this.onPlay,
    required this.onRefresh,
    required this.services,
    this.isVideoFeed = false,
  });

  final List<Post> posts;
  final String? activePostId;
  final bool isPlaying;
  final bool isBuffering;
  final Future<void> Function(Post) onPlay;
  final Future<void> Function() onRefresh;
  final AppServices services;
  final bool isVideoFeed;

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return EmptyState(
        title: isVideoFeed ? 'No music videos yet' : 'No drops yet',
        message: isVideoFeed
            ? 'Upload or generate a music video to see it here! 🎬'
            : 'The feed is quiet. Be the first to post a track! 🔥',
        icon: isVideoFeed ? Icons.videocam_off_rounded : Icons.music_note_rounded,
      );
    }

    return RefreshIndicator(
      color: MoltColors.purple,
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 100),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          final isActive = activePostId == post.id;
          return _FYPCard(
            post: post,
            isActive: isActive,
            isPlaying: isPlaying && isActive,
            isBuffering: isBuffering && isActive,
            onPlay: () => onPlay(post),
            services: services,
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════
// FYP CARD (TikTok-like card)
// ═══════════════════════════════════════

class _FYPCard extends StatefulWidget {
  const _FYPCard({
    required this.post,
    required this.isActive,
    required this.isPlaying,
    required this.isBuffering,
    required this.onPlay,
    required this.services,
  });

  final Post post;
  final bool isActive;
  final bool isPlaying;
  final bool isBuffering;
  final VoidCallback onPlay;
  final AppServices services;

  @override
  State<_FYPCard> createState() => _FYPCardState();
}

class _FYPCardState extends State<_FYPCard> {
  bool _liked = false;
  bool _showComments = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: widget.isActive
            ? LinearGradient(colors: [
                MoltColors.purple.withValues(alpha: 0.15),
                MoltColors.pink.withValues(alpha: 0.1),
              ])
            : MoltColors.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.isActive
              ? MoltColors.purple.withValues(alpha: 0.5)
              : MoltColors.purple.withValues(alpha: 0.1),
          width: widget.isActive ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          // Artwork + play button
          GestureDetector(
            onTap: widget.onPlay,
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    MoltColors.purple.withValues(alpha: 0.3),
                    MoltColors.pink.withValues(alpha: 0.2),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Stack(
                children: [
                  // Artwork
                  if (widget.post.artworkUrl != null)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        child: Image.network(
                          widget.post.artworkUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _artworkFallback(),
                        ),
                      ),
                    )
                  else
                    Positioned.fill(child: _artworkFallback()),

                  // Play button overlay
                  Center(
                    child: widget.isBuffering
                        ? const SizedBox(
                            width: 56,
                            height: 56,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                          )
                        : Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              gradient: MoltColors.purplePinkGradient,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: MoltColors.purple.withValues(alpha: 0.5),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                            child: Icon(
                              widget.isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),

          // Info section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + artist
                Text(
                  widget.post.title,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  widget.post.artist,
                  style: const TextStyle(color: Colors.white54, fontSize: 14),
                ),
                const SizedBox(height: 10),

                // Tags
                if (widget.post.tags.isNotEmpty)
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: widget.post.tags.take(5).map((t) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: MoltColors.purple.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '#$t',
                          style: const TextStyle(fontSize: 11, color: MoltColors.purple),
                        ),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 12),

                // Action bar
                Row(
                  children: [
                    // Like
                    GestureDetector(
                      onTap: () => setState(() => _liked = !_liked),
                      child: Row(
                        children: [
                          Icon(
                            _liked ? Icons.favorite : Icons.favorite_border,
                            color: _liked ? MoltColors.pink : MoltColors.textMuted,
                            size: 22,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.post.likes + (_liked ? 1 : 0)}',
                            style: TextStyle(
                              color: _liked ? MoltColors.pink : MoltColors.textMuted,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),

                    // Comments
                    GestureDetector(
                      onTap: () => setState(() => _showComments = !_showComments),
                      child: Row(
                        children: [
                          Icon(
                            _showComments ? Icons.chat_bubble : Icons.chat_bubble_outline,
                            color: _showComments ? MoltColors.purple : MoltColors.textMuted,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Comments',
                            style: TextStyle(
                              color: _showComments ? MoltColors.purple : MoltColors.textMuted,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),

                    // Share
                    const Icon(Icons.share_outlined, color: MoltColors.textMuted, size: 20),
                    const SizedBox(width: 16),
                    Text(
                      '${widget.post.remixesCount} remixes',
                      style: const TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Comments section
          if (_showComments)
            _CommentsWidget(
              postId: widget.post.id,
              services: widget.services,
            ),
        ],
      ),
    );
  }

  Widget _artworkFallback() {
    return Center(
      child: Text(
        widget.post.artist.isNotEmpty
            ? widget.post.artist[0].toUpperCase()
            : '🎵',
        style: const TextStyle(fontSize: 64, fontWeight: FontWeight.w900),
      ),
    );
  }
}

// ═══════════════════════════════════════
// REUSABLE COMMENTS WIDGET
// ═══════════════════════════════════════

class _CommentsWidget extends StatefulWidget {
  const _CommentsWidget({required this.postId, required this.services});
  final String postId;
  final AppServices services;

  @override
  State<_CommentsWidget> createState() => _CommentsWidgetState();
}

class _CommentsWidgetState extends State<_CommentsWidget> {
  final _commentController = TextEditingController();
  final List<_Comment> _comments = [];
  bool _isLoading = false;
  bool _isPosting = false;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    setState(() => _isLoading = true);
    try {
      final response = await widget.services.apiClient.dio
          .get('/posts/${widget.postId}/comments');
      final data = response.data;
      final list = (data is List) ? data : (data['comments'] ?? []);
      setState(() {
        _comments.clear();
        for (final c in list) {
          _comments.add(_Comment(
            username: c['username'] ?? 'Anonymous',
            text: c['text'] ?? '',
            createdAt: c['created_at'] ?? '',
          ));
        }
      });
    } catch (_) {
      // Comments endpoint might not exist yet — show empty
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _postComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isPosting = true);
    try {
      await widget.services.apiClient.dio.post(
        '/posts/${widget.postId}/comments',
        data: {'text': text},
      );
      _commentController.clear();
      await _loadComments();
    } catch (_) {
      // If endpoint doesn't exist, add locally
      setState(() {
        _comments.insert(0, _Comment(
          username: 'You',
          text: text,
          createdAt: DateTime.now().toIso8601String(),
        ));
        _commentController.clear();
      });
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(color: MoltColors.surfaceLight),
          const SizedBox(height: 8),
          Text(
            'Comments',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),

          // Input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: const InputDecoration(
                    hintText: 'Write a comment...',
                    hintStyle: TextStyle(color: MoltColors.textMuted, fontSize: 12),
                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    isDense: true,
                  ),
                  onSubmitted: (_) => _postComment(),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _isPosting ? null : _postComment,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: MoltColors.purplePinkGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _isPosting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.send, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Comments list
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: MoltColors.purple, strokeWidth: 2),
                ),
              ),
            )
          else if (_comments.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  'No comments yet. Be the first! 💬',
                  style: TextStyle(color: MoltColors.textMuted, fontSize: 12),
                ),
              ),
            )
          else
            ...(_comments.take(10).map((c) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        gradient: MoltColors.purplePinkGradient,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          c.username.isNotEmpty ? c.username[0].toUpperCase() : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.username,
                            style: const TextStyle(
                              color: MoltColors.purple,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            c.text,
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            })),
        ],
      ),
    );
  }
}

class _Comment {
  _Comment({required this.username, required this.text, required this.createdAt});
  final String username;
  final String text;
  final String createdAt;
}
