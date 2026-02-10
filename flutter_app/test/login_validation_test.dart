import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:molt_musical_media/app/services.dart';
import 'package:molt_musical_media/features/auth/login_screen.dart';

void main() {
  testWidgets('Login validates required fields', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LoginScreen(services: AppServices()),
      ),
    );

    await tester.tap(find.text('Sign In'));
    await tester.pump();

    expect(find.text('Email and password are required.'), findsOneWidget);
  });
}
