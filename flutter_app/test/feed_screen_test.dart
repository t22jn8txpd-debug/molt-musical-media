import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:molt_musical_media/app/services.dart';
import 'package:molt_musical_media/features/feed/feed_screen.dart';

import 'helpers/test_services.dart';

void main() {
  testWidgets('Feed renders posts', (WidgetTester tester) async {
    final fakeClient = FakeApiClient(
      onRequest: (options) => Response(
        requestOptions: options,
        data: {
          'posts': [
            {
              'id': 'post-1',
              'title': 'Midnight Bounce',
              'username': 'DJ Test',
              'content_url': 'https://example.com/track.mp3',
              'tags': ['lofi']
            }
          ]
        },
        statusCode: 200,
      ),
    );

    final services = AppServices(
      apiClient: fakeClient,
      tokenStore: const FakeTokenStore(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: FeedScreen(services: services),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Midnight Bounce'), findsOneWidget);
    expect(find.text('DJ Test'), findsOneWidget);
  });
}
