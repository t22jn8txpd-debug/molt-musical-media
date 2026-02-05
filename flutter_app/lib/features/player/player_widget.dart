import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../core/models/post.dart';

class PlayerWidget extends StatelessWidget {
  const PlayerWidget({
    super.key,
    required this.post,
    required this.player,
    required this.isActive,
    required this.isBuffering,
    required this.onPlayPause,
  });

  final Post post;
  final AudioPlayer player;
  final bool isActive;
  final bool isBuffering;
  final VoidCallback onPlayPause;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF121721),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _PlayButton(
                isActive: isActive,
                isPlaying: player.playing,
                isBuffering: isBuffering,
                onPressed: onPlayPause,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Session preview',
                      style: theme.textTheme.labelLarge?.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: 6),
                    _WaveformPlaceholder(isActive: isActive),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _PlaybackSlider(player: player, enabled: isActive),
        ],
      ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton({
    required this.isActive,
    required this.isPlaying,
    required this.isBuffering,
    required this.onPressed,
  });

  final bool isActive;
  final bool isPlaying;
  final bool isBuffering;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      width: 52,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isActive
              ? const [Color(0xFF4DD7C8), Color(0xFF90A7FF)]
              : const [Color(0xFF2A3243), Color(0xFF202634)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: IconButton(
        icon: isBuffering && isActive
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(isPlaying && isActive ? Icons.pause : Icons.play_arrow),
        color: isActive ? const Color(0xFF0F1115) : Colors.white,
        onPressed: onPressed,
      ),
    );
  }
}

class _WaveformPlaceholder extends StatelessWidget {
  const _WaveformPlaceholder({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final bars = List.generate(18, (index) => (index * 7 % 12 + 6).toDouble());
    return Row(
      children: bars
          .map(
            (height) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1.5),
                child: Container(
                  height: height,
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0xFF4DD7C8) : const Color(0xFF3A455A),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _PlaybackSlider extends StatelessWidget {
  const _PlaybackSlider({required this.player, required this.enabled});

  final AudioPlayer player;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration>(
      stream: player.positionStream,
      builder: (context, snapshot) {
        final position = snapshot.data ?? Duration.zero;
        final duration = player.duration ?? Duration.zero;
        final max = duration.inMilliseconds > 0 ? duration.inMilliseconds.toDouble() : 1.0;
        final value = position.inMilliseconds.toDouble().clamp(0.0, max).toDouble();
        return SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
          ),
          child: Slider(
            value: value,
            max: max,
            onChanged: enabled
                ? (newValue) {
                    player.seek(Duration(milliseconds: newValue.toInt()));
                  }
                : null,
          ),
        );
      },
    );
  }
}
