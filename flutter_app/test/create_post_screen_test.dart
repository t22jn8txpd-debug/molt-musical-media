import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:molt_musical_media/app/services.dart';
import 'package:molt_musical_media/features/post/create_post_screen.dart';

import 'helpers/test_services.dart';

void main() {
  testWidgets('Create post submits and shows success', (WidgetTester tester) async {
    final fakeClient = FakeApiClient(
      onRequest: (options) => Response(
        requestOptions: options,
        data: {},
        statusCode: 201,
      ),
    );

    final services = AppServices(
      apiClient: fakeClient,
      tokenStore: const FakeTokenStore(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: CreatePostScreen(services: services),
      ),
    );

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Test track');
    await tester.enterText(fields.at(2), 'https://example.com/audio.mp3');

    await tester.tap(find.text('Post Track'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Track posted successfully! 🔥'), findsOneWidget);
  });
}
