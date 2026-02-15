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

/// A user/Molt profile screen.
/// Pass [userId] to view someone else's profile, or null for the current user.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.services, this.userId});

  final AppServices services;
  final String? userId;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? _profile;
  List<Post> _tracks = [];
  bool _isLoading = true;
  bool _isFollowing = false;
  bool _followLoading = false;
  int _followerCount = 0;
  int _followingCount = 0;
  String? _error;

  final AudioPlayer _player = AudioPlayer();
  String? _activePostId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadProfile();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _player.dispose();
    super.dispose();
  }

  bool get _isOwnProfile => widget.userId == null;

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final endpoint = _isOwnProfile
          ? '/profile/me'
          : '/profile/${widget.userId}';
      final response =
          await widget.services.apiClient.dio.get(endpoint);
      final data = response.data;
      setState(() {
        _profile = data['user'] ?? data;
        _followerCount = data['follower_count'] ?? 0;
        _followingCount = data['following_count'] ?? 0;
        _isFollowing = data['is_following'] ?? false;
      });

      // Load tracks
      final postsEndpoint = _isOwnProfile
          ? '/posts/mine'
          : '/posts/user/${widget.userId}';
      try {
        final postsRes =
            await widget.services.apiClient.dio.get(postsEndpoint);
        final postsData = postsRes.data;
        final postsList = (postsData is List)
            ? postsData
            : (postsData['posts'] ?? []);
        setState(() {
          _tracks = (postsList as List)
              .map((p) => Post.fromJson(p as Map<String, dynamic>))
              .toList();
        });
      } catch (_) {
        // Posts endpoint might not exist yet
      }
    } catch (e) {
      setState(() => _error = 'Could not load profile.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleFollow() async {
    if (_isOwnProfile) return;
    setState(() => _followLoading = true);
    try {
      if (_isFollowing) {
        await widget.services.apiClient.dio
            .delete('/profile/${widget.userId}/follow');
        setState(() {
          _isFollowing = false;
          _followerCount = (_followerCount - 1).clamp(0, 999999);
        });
      } else {
        await widget.services.apiClient.dio
            .post('/profile/${widget.userId}/follow');
        setState(() {
          _isFollowing = true;
          _followerCount++;
        });
      }
    } catch (_) {
      // Silently fail
    } finally {
      if (mounted) setState(() => _followLoading = false);
    }
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
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        decoration:
            const BoxDecoration(gradient: MoltColors.backgroundGradient),
        child: const LoadingState(label: 'Loading profile...'),
      );
    }

    if (_error != null) {
      return Container(
        decoration:
            const BoxDecoration(gradient: MoltColors.backgroundGradient),
        child: EmptyState(
          title: 'Oops',
          message: _error!,
          icon: Icons.error_outline,
        ),
      );
    }

    final username = _profile?['username'] ?? 'Unknown';
    final bio = _profile?['bio'] ?? '';
    final avatarUrl = _profile?['avatar_url'];
    final userType = _profile?['type'] ?? 'human';
    final isMolt = userType == 'molt';

    return Container(
      decoration:
          const BoxDecoration(gradient: MoltColors.backgroundGradient),
      child: CustomScrollView(
        slivers: [
          // Profile header
          SliverToBoxAdapter(
            child: _ProfileHeader(
              username: username,
              bio: bio,
              avatarUrl: avatarUrl,
              isMolt: isMolt,
              isOwnProfile: _isOwnProfile,
              isFollowing: _isFollowing,
              followLoading: _followLoading,
              followerCount: _followerCount,
              followingCount: _followingCount,
              trackCount: _tracks.length,
              onFollow: _toggleFollow,
            ),
          ),

          // Tabs
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: MoltColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: MoltColors.purple.withValues(alpha: 0.2)),
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
                labelStyle: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 13),
                tabs: const [
                  Tab(text: '🎵 Tracks'),
                  Tab(text: '💿 Albums'),
                  Tab(text: '🎬 Videos'),
                  Tab(text: '❤️ Liked'),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // Track list (simple for all tabs for now)
          if (_tracks.isEmpty)
            const SliverFillRemaining(
              child: EmptyState(
                title: 'No tracks yet',
                message: 'This artist hasn\'t posted any tracks yet.',
                icon: Icons.music_off_rounded,
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final track = _tracks[index];
                    final isActive = _activePostId == track.id;
                    return _TrackListItem(
                      track: track,
                      index: index + 1,
                      isActive: isActive,
                      isPlaying: _player.playing && isActive,
                      onPlay: () => _togglePlay(track),
                    );
                  },
                  childCount: _tracks.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.username,
    required this.bio,
    this.avatarUrl,
    required this.isMolt,
    required this.isOwnProfile,
    required this.isFollowing,
    required this.followLoading,
    required this.followerCount,
    required this.followingCount,
    required this.trackCount,
    required this.onFollow,
  });

  final String username;
  final String bio;
  final String? avatarUrl;
  final bool isMolt;
  final bool isOwnProfile;
  final bool isFollowing;
  final bool followLoading;
  final int followerCount;
  final int followingCount;
  final int trackCount;
  final VoidCallback onFollow;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        children: [
          // Banner gradient
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: isMolt
                  ? MoltColors.purplePinkGradient
                  : MoltColors.purpleBlueGradient,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Type badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isMolt ? '🤖 Molt Agent' : '👤 Human Artist',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                // Avatar
                Positioned(
                  bottom: -36,
                  left: 20,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: MoltColors.purplePinkGradient,
                      borderRadius: BorderRadius.circular(22),
                      border:
                          Border.all(color: MoltColors.darker, width: 4),
                      boxShadow: [
                        BoxShadow(
                            color:
                                MoltColors.purple.withValues(alpha: 0.4),
                            blurRadius: 20),
                      ],
                    ),
                    child: avatarUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Image.network(avatarUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _avatarFallback()),
                          )
                        : _avatarFallback(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 44),

          // Name + bio
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          username,
                          style: GoogleFonts.inter(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.white),
                        ),
                        if (isMolt) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.verified,
                              color: MoltColors.purple, size: 20),
                        ],
                      ],
                    ),
                    if (bio.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(bio,
                          style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              height: 1.4)),
                    ],
                  ],
                ),
              ),
              if (!isOwnProfile)
                SizedBox(
                  width: 120,
                  child: followLoading
                      ? const Center(
                          child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2)))
                      : GradientButton(
                          label: isFollowing ? 'Following' : 'Follow',
                          icon:
                              isFollowing ? Icons.check : Icons.person_add,
                          onPressed: onFollow,
                          height: 40,
                          gradient: isFollowing
                              ? const LinearGradient(colors: [
                                  MoltColors.surface,
                                  MoltColors.surface
                                ])
                              : null,
                        ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Stats row
          Row(
            children: [
              _StatPill(count: trackCount, label: 'Tracks'),
              const SizedBox(width: 12),
              _StatPill(count: followerCount, label: 'Followers'),
              const SizedBox(width: 12),
              _StatPill(count: followingCount, label: 'Following'),
            ],
          ),

          // Action buttons for own profile
          if (isOwnProfile) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: GradientButton(
                    label: '✏️ Edit Profile',
                    onPressed: () {},
                    height: 40,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GradientButton(
                    label: '🔑 API Keys',
                    onPressed: () {},
                    height: 40,
                    gradient: MoltColors.purpleBlueGradient,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _avatarFallback() {
    return Center(
      child: Text(
        username.isNotEmpty ? username[0].toUpperCase() : '?',
        style: const TextStyle(
            color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.count, required this.label});
  final int count;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: MoltColors.surface,
        borderRadius: BorderRadius.circular(10),
        border:
            Border.all(color: MoltColors.purple.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Text('$count',
              style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16)),
          Text(label,
              style: const TextStyle(
                  color: MoltColors.textMuted, fontSize: 10)),
        ],
      ),
    );
  }
}

class _TrackListItem extends StatelessWidget {
  const _TrackListItem({
    required this.track,
    required this.index,
    required this.isActive,
    required this.isPlaying,
    required this.onPlay,
  });

  final Post track;
  final int index;
  final bool isActive;
  final bool isPlaying;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: isActive
            ? LinearGradient(colors: [
                MoltColors.purple.withValues(alpha: 0.15),
                MoltColors.pink.withValues(alpha: 0.1),
              ])
            : MoltColors.cardGradient,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive
              ? MoltColors.purple.withValues(alpha: 0.4)
              : MoltColors.purple.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          // Track number
          SizedBox(
            width: 28,
            child: Text(
              '$index',
              style: TextStyle(
                color: isActive ? MoltColors.purple : MoltColors.textMuted,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
          // Play button
          GestureDetector(
            onTap: onPlay,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient:
                    isActive ? MoltColors.purplePinkGradient : null,
                color: isActive ? null : MoltColors.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Title + tags
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(track.title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                if (track.tags.isNotEmpty)
                  Text(
                    track.tags.take(3).map((t) => '#$t').join(' '),
                    style: const TextStyle(
                        color: MoltColors.textMuted, fontSize: 11),
                  ),
              ],
            ),
          ),
          // Likes
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.favorite, color: MoltColors.pink, size: 14),
              const SizedBox(width: 4),
              Text('${track.likes}',
                  style: const TextStyle(
                      color: MoltColors.textMuted, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
