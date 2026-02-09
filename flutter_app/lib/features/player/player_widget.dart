import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../app/theme.dart';
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: MoltColors.darker.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? MoltColors.purple.withValues(alpha: 0.4)
              : MoltColors.purple.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _PlayButton(
                isActive: isActive,
                isPlaying: player.playing,
                isBuffering: isBuffering,
                onPressed: onPlayPause,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isActive ? 'Now Playing' : 'Tap to play',
                      style: TextStyle(
                        color: isActive ? MoltColors.purple : MoltColors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _WaveformBars(isActive: isActive),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
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
        gradient: isActive ? MoltColors.purplePinkGradient : null,
        color: isActive ? null : MoltColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: MoltColors.purple.withValues(alpha: 0.5),
                  blurRadius: 16,
                ),
              ]
            : null,
      ),
      child: IconButton(
        icon: isBuffering && isActive
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(
                isPlaying && isActive ? Icons.pause_rounded : Icons.play_arrow_rounded,
                size: 28,
              ),
        color: Colors.white,
        onPressed: onPressed,
      ),
    );
  }
}

class _WaveformBars extends StatelessWidget {
  const _WaveformBars({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final bars = List.generate(22, (i) => (i * 7 % 12 + 4).toDouble());
    return Row(
      children: bars
          .map(
            (height) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: Container(
                  height: height,
                  decoration: BoxDecoration(
                    gradient: isActive
                        ? LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              MoltColors.purple,
                              MoltColors.pink.withValues(alpha: 0.7),
                            ],
                          )
                        : null,
                    color: isActive ? null : MoltColors.surfaceLight,
                    borderRadius: BorderRadius.circular(3),
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

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(1, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration>(
      stream: player.positionStream,
      builder: (context, snapshot) {
        final position = snapshot.data ?? Duration.zero;
        final duration = player.duration ?? Duration.zero;
        final max = duration.inMilliseconds > 0 ? duration.inMilliseconds.toDouble() : 1.0;
        final value = position.inMilliseconds.toDouble().clamp(0.0, max);

        return Column(
          children: [
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                activeTrackColor: MoltColors.purple,
                inactiveTrackColor: MoltColors.surfaceLight,
                thumbColor: MoltColors.purple,
                overlayColor: MoltColors.purple.withValues(alpha: 0.2),
              ),
              child: Slider(
                value: value,
                max: max,
                onChanged: enabled
                    ? (v) => player.seek(Duration(milliseconds: v.toInt()))
                    : null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(position),
                    style: const TextStyle(color: MoltColors.textMuted, fontSize: 11),
                  ),
                  Text(
                    _formatDuration(duration),
                    style: const TextStyle(color: MoltColors.textMuted, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
