import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../app/services.dart';
import '../../core/models/post.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/loading_state.dart';
import '../../shared/widgets/offline_hint.dart';
import '../player/player_widget.dart';
import 'feed_service.dart';
import 'widgets/post_card.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key, required this.services});

  final AppServices services;

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  late Future<List<Post>> _feedFuture;
  final AudioPlayer _player = AudioPlayer();
  String? _activePostId;
  bool _isBuffering = false;
  late final StreamSubscription<PlayerState> _playerStateSub;

  @override
  void initState() {
    super.initState();
    _feedFuture = FeedService(widget.services.apiClient).fetchFeed();
    _playerStateSub = _player.playerStateStream.listen((state) {
      if (!mounted) return;
      setState(() {
        _isBuffering = state.processingState == ProcessingState.loading ||
            state.processingState == ProcessingState.buffering;
      });
    });
  }

  @override
  void dispose() {
    _playerStateSub.cancel();
    _player.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() {
      _feedFuture = FeedService(widget.services.apiClient).fetchFeed();
    });
    await _feedFuture;
  }

  Future<void> _togglePlay(Post post) async {
    if (post.audioUrl.isEmpty) return;
    final isSame = _activePostId == post.id;
    if (isSame && _player.playing) {
      await _player.pause();
      return;
    }

    try {
      setState(() => _activePostId = post.id);
      await _player.setUrl(post.audioUrl);
      await _player.play();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Playback failed. Try again soon.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Post>>(
      future: _feedFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingState(label: 'Loading fresh drops...');
        }

        final posts = snapshot.data ?? [];
        if (posts.isEmpty) {
          return const EmptyState(
            title: 'No drops yet',
            message: 'Your feed is quiet. Follow artists or refresh soon.',
          );
        }

        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            itemCount: posts.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: OfflineHint(),
                );
              }
              final post = posts[index - 1];
              final isActive = _activePostId == post.id;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: PostCard(
                  post: post,
                  child: PlayerWidget(
                    post: post,
                    player: _player,
                    isActive: isActive,
                    isBuffering: _isBuffering,
                    onPlayPause: () => _togglePlay(post),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
