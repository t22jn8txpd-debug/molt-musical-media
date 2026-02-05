import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:molt_musical_media/app/services.dart';
import 'package:molt_musical_media/features/auth/login_screen.dart';

void main() {
  testWidgets('Login screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LoginScreen(services: AppServices()),
      ),
    );

    expect(find.text('Welcome back'), findsOneWidget);
  });
}
