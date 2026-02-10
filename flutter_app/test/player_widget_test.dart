import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:molt_musical_media/core/models/post.dart';
import 'package:molt_musical_media/features/player/player_widget.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Player widget shows active state', (WidgetTester tester) async {
    final player = AudioPlayer();
    final post = Post(
      id: 'post-1',
      title: 'Test',
      artist: 'Tester',
      audioUrl: 'https://example.com/audio.mp3',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PlayerWidget(
            post: post,
            player: player,
            isActive: false,
            isBuffering: false,
            onPlayPause: () {},
          ),
        ),
      ),
    );

    expect(find.text('Tap to play'), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PlayerWidget(
            post: post,
            player: player,
            isActive: true,
            isBuffering: true,
            onPlayPause: () {},
          ),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Now Playing'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await player.dispose();
  });
}
